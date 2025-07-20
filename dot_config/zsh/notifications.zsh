# Notification System - Zero false positives, Rust-grade reliability
# Only notify when it matters, handle all error cases

# Check if we can send notifications
_can_notify() {
    command -v notify-send >/dev/null 2>&1 || command -v osascript >/dev/null 2>&1
}

# Send notification with error handling
_send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if ! _can_notify; then
        echo "🔔 $title: $message"
        return 0
    fi
    
    # macOS notification
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    fi
}

# Run command with completion notification
nrun() {
    local start_time=$(date +%s)
    local command_line="$*"
    
    if [[ -z "$command_line" ]]; then
        echo "Error: No command specified" >&2
        echo "Usage: nrun <command>" >&2
        return 1
    fi
    
    echo "🚀 Running with notifications: $command_line"
    
    # Execute the command
    if "$@"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local duration_human=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
        
        _send_notification "✅ Command Completed" "Finished in $duration_human: $command_line" "normal"
        echo "✅ Command completed successfully in $duration_human"
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local duration_human=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
        
        _send_notification "❌ Command Failed" "Failed after $duration_human: $command_line" "critical"
        echo "❌ Command failed with exit code $exit_code after $duration_human"
        return $exit_code
    fi
}

# Smart notification for long-running commands (only if they take > threshold)
nsmart() {
    local threshold="${NRUN_THRESHOLD:-30}"  # Default 30 seconds
    local start_time=$(date +%s)
    local command_line="$*"
    
    if [[ -z "$command_line" ]]; then
        echo "Error: No command specified" >&2
        echo "Usage: nsmart <command>" >&2
        return 1
    fi
    
    # Execute the command
    if "$@"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # Only notify if it took longer than threshold
        if [[ $duration -gt $threshold ]]; then
            local duration_human=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
            _send_notification "✅ Long Task Completed" "Finished in $duration_human: $(echo "$command_line" | cut -c1-50)..." "normal"
        fi
        
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # Always notify on failure, regardless of duration
        local duration_human=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
        _send_notification "❌ Command Failed" "Failed after $duration_human: $(echo "$command_line" | cut -c1-50)..." "critical"
        
        return $exit_code
    fi
}

# Background task management with notifications
nbg() {
    local task_name="${1:-background-task}"
    shift
    local command_line="$*"
    
    if [[ -z "$command_line" ]]; then
        echo "Error: No command specified" >&2
        echo "Usage: nbg <task_name> <command>" >&2
        return 1
    fi
    
    local log_file="/tmp/nbg-$task_name-$(date +%s).log"
    local pid_file="/tmp/nbg-$task_name.pid"
    
    echo "🔄 Starting background task: $task_name"
    echo "📝 Logs: $log_file"
    
    # Start the task in background
    (
        local start_time=$(date +%s)
        echo "Started at: $(date)" > "$log_file"
        echo "Command: $command_line" >> "$log_file"
        echo "════════════════════════" >> "$log_file"
        
        if eval "$command_line" >> "$log_file" 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local duration_human=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
            
            echo "✅ Completed at: $(date)" >> "$log_file"
            _send_notification "✅ Background Task Complete" "$task_name finished in $duration_human" "normal"
        else
            local exit_code=$?
            echo "❌ Failed at: $(date) with exit code $exit_code" >> "$log_file"
            _send_notification "❌ Background Task Failed" "$task_name failed (exit $exit_code)" "critical"
        fi
        
        # Clean up PID file
        rm -f "$pid_file"
    ) &
    
    local bg_pid=$!
    echo "$bg_pid" > "$pid_file"
    
    echo "🆔 Background PID: $bg_pid"
    echo "🛑 Stop with: nkill $task_name"
    
    return 0
}

# Kill background task
nkill() {
    local task_name="$1"
    
    if [[ -z "$task_name" ]]; then
        echo "Error: No task name specified" >&2
        echo "Usage: nkill <task_name>" >&2
        return 1
    fi
    
    local pid_file="/tmp/nbg-$task_name.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            _send_notification "🛑 Background Task Stopped" "Killed task: $task_name" "normal"
            echo "🛑 Killed background task: $task_name (PID: $pid)"
        else
            echo "⚠️  Task $task_name is not running"
        fi
        rm -f "$pid_file"
    else
        echo "❌ No background task named: $task_name"
        return 1
    fi
}

# List active background tasks
nlist() {
    echo "📋 Active background tasks:"
    local found=false
    
    for pid_file in /tmp/nbg-*.pid; do
        if [[ -f "$pid_file" ]]; then
            local task_name=$(basename "$pid_file" .pid | sed 's/^nbg-//')
            local pid=$(cat "$pid_file")
            
            if kill -0 "$pid" 2>/dev/null; then
                echo "   🔄 $task_name (PID: $pid)"
                found=true
            else
                # Clean up stale PID file
                rm -f "$pid_file"
            fi
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        echo "   (none)"
    fi
}

# Aliases for common use cases
alias ntest='nsmart cargo nextest run'
alias nbuild='nsmart cargo build --release'
alias ntrain='nbg training'