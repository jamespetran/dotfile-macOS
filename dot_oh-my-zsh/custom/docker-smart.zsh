# Smart Docker Integration for macOS with Colima
# Implements lazy initialization and auto-cleanup like Rust's borrow system
# 
# Features:
# - Lazy start: Colima starts only when Docker commands are used
# - Auto-cleanup: Stops Colima after configurable idle time
# - Resource management: Tracks active containers and usage
# - Transparent operation: Works with all Docker commands seamlessly
# - Performance optimized: Minimal overhead when Docker isn't needed

# Configuration
export DOCKER_SMART_ENABLED=${DOCKER_SMART_ENABLED:-true}
export DOCKER_IDLE_TIMEOUT=${DOCKER_IDLE_TIMEOUT:-600}  # 10 minutes default
export DOCKER_CLEANUP_AGGRESSIVE=${DOCKER_CLEANUP_AGGRESSIVE:-false}
export DOCKER_SMART_LOG_LEVEL=${DOCKER_SMART_LOG_LEVEL:-1}  # 0=silent, 1=info, 2=debug

# State tracking
DOCKER_SMART_STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/docker-smart"
DOCKER_LAST_ACTIVITY_FILE="$DOCKER_SMART_STATE_DIR/last_activity"
DOCKER_CLEANUP_PID_FILE="$DOCKER_SMART_STATE_DIR/cleanup_pid"
DOCKER_STARTUP_LOCK_FILE="$DOCKER_SMART_STATE_DIR/startup_lock"

# Ensure state directory exists
mkdir -p "$DOCKER_SMART_STATE_DIR"

# Logging functions
_docker_log() {
    local level=$1
    shift
    if [[ $DOCKER_SMART_LOG_LEVEL -ge $level ]]; then
        echo "[docker-smart] $*" >&2
    fi
}

_docker_debug() { _docker_log 2 "$@"; }
_docker_info() { _docker_log 1 "$@"; }

# Check if Colima is running
_docker_is_running() {
    docker info >/dev/null 2>&1
}

# Check if there are active containers
_docker_has_active_containers() {
    if ! _docker_is_running; then
        return 1
    fi
    
    local running_count
    running_count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
    [[ $running_count -gt 0 ]]
}

# Update last activity timestamp
_docker_update_activity() {
    echo "$(date +%s)" > "$DOCKER_LAST_ACTIVITY_FILE"
}

# Get seconds since last activity
_docker_seconds_since_activity() {
    if [[ ! -f "$DOCKER_LAST_ACTIVITY_FILE" ]]; then
        echo 999999
        return
    fi
    
    local last_activity current_time
    last_activity=$(cat "$DOCKER_LAST_ACTIVITY_FILE" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    echo $((current_time - last_activity))
}

# Start Colima with optimized settings
_docker_start_colima() {
    if _docker_is_running; then
        _docker_debug "Colima already running"
        return 0
    fi
    
    # Prevent concurrent startups
    if [[ -f "$DOCKER_STARTUP_LOCK_FILE" ]]; then
        local lock_age=$(($(date +%s) - $(stat -f %m "$DOCKER_STARTUP_LOCK_FILE" 2>/dev/null || echo 0)))
        if [[ $lock_age -lt 60 ]]; then
            _docker_info "Waiting for concurrent startup..."
            sleep 2
            return $(_docker_start_colima)
        else
            rm -f "$DOCKER_STARTUP_LOCK_FILE"
        fi
    fi
    
    touch "$DOCKER_STARTUP_LOCK_FILE"
    
    _docker_info "Starting Colima..."
    
    # Check if colima is installed
    if ! command -v colima >/dev/null 2>&1; then
        _docker_info "Installing Colima and Docker CLI..."
        brew install colima docker docker-compose
    fi
    
    # Start Colima with optimal settings for Apple Silicon
    local start_cmd="colima start"
    
    # Check if we have an existing profile/config
    if [[ -f "$HOME/.colima/default.yaml" ]]; then
        _docker_debug "Using existing Colima configuration"
    else
        # Use optimized defaults for Apple Silicon
        start_cmd="$start_cmd --cpu 4 --memory 8 --disk 100 --vm-type vz --vz-rosetta --network-address"
    fi
    
    if eval "$start_cmd" >/dev/null 2>&1; then
        # Wait for Docker to be ready
        local count=0
        while ! _docker_is_running && [[ $count -lt 30 ]]; do
            sleep 1
            ((count++))
        done
        
        rm -f "$DOCKER_STARTUP_LOCK_FILE"
        
        if _docker_is_running; then
            _docker_info "Docker ready via Colima"
            _docker_update_activity
            _docker_schedule_cleanup
            return 0
        else
            _docker_info "Docker failed to start within 30s"
            rm -f "$DOCKER_STARTUP_LOCK_FILE"
            return 1
        fi
    else
        rm -f "$DOCKER_STARTUP_LOCK_FILE"
        _docker_info "Failed to start Colima"
        return 1
    fi
}

# Stop Colima gracefully
_docker_stop_colima() {
    if ! _docker_is_running; then
        _docker_debug "Colima not running"
        return 0
    fi
    
    _docker_info "Stopping Colima..."
    colima stop >/dev/null 2>&1
    
    # Kill any existing cleanup processes
    _docker_cancel_cleanup
}

# Schedule automatic cleanup
_docker_schedule_cleanup() {
    # Cancel any existing cleanup
    _docker_cancel_cleanup
    
    # Start new cleanup process in background
    (
        sleep "$DOCKER_IDLE_TIMEOUT"
        
        # Check if we should actually clean up
        if [[ $(_docker_seconds_since_activity) -ge $DOCKER_IDLE_TIMEOUT ]]; then
            if _docker_has_active_containers; then
                _docker_debug "Skipping cleanup: active containers running"
                # Reschedule for later
                _docker_schedule_cleanup
            else
                _docker_info "Auto-stopping Colima after ${DOCKER_IDLE_TIMEOUT}s idle"
                
                # Optional aggressive cleanup
                if [[ "$DOCKER_CLEANUP_AGGRESSIVE" == "true" ]]; then
                    _docker_debug "Performing aggressive cleanup"
                    docker system prune -f >/dev/null 2>&1 || true
                fi
                
                _docker_stop_colima
            fi
        else
            # Activity detected, reschedule
            _docker_debug "Activity detected, rescheduling cleanup"
            _docker_schedule_cleanup
        fi
    ) &
    
    echo $! > "$DOCKER_CLEANUP_PID_FILE"
    disown
}

# Cancel scheduled cleanup
_docker_cancel_cleanup() {
    if [[ -f "$DOCKER_CLEANUP_PID_FILE" ]]; then
        local cleanup_pid
        cleanup_pid=$(cat "$DOCKER_CLEANUP_PID_FILE" 2>/dev/null)
        if [[ -n "$cleanup_pid" ]] && kill -0 "$cleanup_pid" 2>/dev/null; then
            kill "$cleanup_pid" 2>/dev/null || true
        fi
        rm -f "$DOCKER_CLEANUP_PID_FILE"
    fi
}

# Main Docker wrapper function
_docker_smart_wrapper() {
    if [[ "$DOCKER_SMART_ENABLED" != "true" ]]; then
        command docker "$@"
        return $?
    fi
    
    # Ensure Colima is running
    if ! _docker_start_colima; then
        _docker_info "Failed to start Docker runtime"
        return 1
    fi
    
    # Update activity and execute command
    _docker_update_activity
    
    # Execute the actual Docker command
    local exit_code
    command docker "$@"
    exit_code=$?
    
    # Update activity after command completion
    _docker_update_activity
    
    return $exit_code
}

# Docker Compose wrapper
_docker_compose_smart_wrapper() {
    if [[ "$DOCKER_SMART_ENABLED" != "true" ]]; then
        command docker compose "$@"
        return $?
    fi
    
    # Ensure Colima is running
    if ! _docker_start_colima; then
        _docker_info "Failed to start Docker runtime"
        return 1
    fi
    
    # Update activity and execute command
    _docker_update_activity
    
    # Execute the actual Docker Compose command
    local exit_code
    command docker compose "$@"
    exit_code=$?
    
    # Update activity after command completion
    _docker_update_activity
    
    return $exit_code
}

# Override docker and docker-compose commands
if [[ "$DOCKER_SMART_ENABLED" == "true" ]]; then
    docker() { _docker_smart_wrapper "$@"; }
    
    # Handle both "docker compose" and "docker-compose" patterns
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose() { _docker_compose_smart_wrapper "$@"; }
    fi
fi

# Management commands
docker-smart-status() {
    echo "Docker Smart Status:"
    echo "  Enabled: $DOCKER_SMART_ENABLED"
    echo "  Idle timeout: ${DOCKER_IDLE_TIMEOUT}s"
    echo "  Aggressive cleanup: $DOCKER_CLEANUP_AGGRESSIVE"
    echo "  Log level: $DOCKER_SMART_LOG_LEVEL"
    echo ""
    
    if _docker_is_running; then
        echo "  Colima status: Running"
        local container_count
        container_count=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        echo "  Running containers: $container_count"
        
        local seconds_idle
        seconds_idle=$(_docker_seconds_since_activity)
        echo "  Idle time: ${seconds_idle}s"
        
        if [[ -f "$DOCKER_CLEANUP_PID_FILE" ]]; then
            echo "  Cleanup scheduled: Yes"
        else
            echo "  Cleanup scheduled: No"
        fi
    else
        echo "  Colima status: Stopped"
        echo "  Running containers: 0"
    fi
}

docker-smart-stop() {
    _docker_info "Manually stopping Docker Smart"
    _docker_stop_colima
}

docker-smart-start() {
    _docker_info "Manually starting Docker Smart"
    _docker_start_colima
}

docker-smart-reset() {
    _docker_info "Resetting Docker Smart state"
    _docker_cancel_cleanup
    rm -f "$DOCKER_LAST_ACTIVITY_FILE" "$DOCKER_CLEANUP_PID_FILE" "$DOCKER_STARTUP_LOCK_FILE"
    _docker_info "State reset complete"
}

# Cleanup on shell exit
_docker_smart_cleanup_on_exit() {
    _docker_cancel_cleanup
}

# Register cleanup hook
if [[ "$DOCKER_SMART_ENABLED" == "true" ]]; then
    # Add cleanup trap for shell exit
    trap '_docker_smart_cleanup_on_exit' EXIT
    
    # Initialize on first load (but don't start Colima unless needed)
    _docker_debug "Docker Smart initialized (idle timeout: ${DOCKER_IDLE_TIMEOUT}s)"
fi

# Export configuration for subshells
export DOCKER_SMART_ENABLED DOCKER_IDLE_TIMEOUT DOCKER_CLEANUP_AGGRESSIVE DOCKER_SMART_LOG_LEVEL