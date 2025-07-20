# Container Runtime Integration for macOS
# Now powered by docker-smart.zsh for intelligent auto-start and cleanup

# Configuration - these work with docker-smart.zsh
export CONTAINER_RUNTIME="docker"
export COMPOSE_COMMAND="docker compose"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Smart Docker configuration (see docker-smart.zsh)
# DOCKER_SMART_ENABLED=true        # Enable smart Docker management
# DOCKER_IDLE_TIMEOUT=600          # Stop Colima after 10min idle
# DOCKER_CLEANUP_AGGRESSIVE=false  # Aggressive cleanup on stop
# DOCKER_SMART_LOG_LEVEL=1         # Logging level (0=silent, 1=info, 2=debug)

# Legacy compatibility functions
docker_status() {
  docker-smart-status
}

docker_start() {
  docker-smart-start
}

# Simple status check
docker_is_running() {
  docker info &>/dev/null 2>&1
}

# Development container helpers
container_dev_build() {
  local name="${1:-dev}"
  local dockerfile="${2:-Dockerfile}"
  docker build -t "$name" -f "$dockerfile" .
}

container_dev_run() {
  local name="${1:-dev}"
  shift
  docker run -it --rm \
    -v "$PWD:/workspace" \
    -w /workspace \
    --name "${name}-container" \
    "$name" "$@"
}

# Cleanup functions
container_prune() {
  echo "Pruning stopped containers..."
  docker container prune -f
  echo "Pruning unused images..."
  docker image prune -f
  echo "Pruning unused volumes..."
  docker volume prune -f
  echo "Cleanup complete!"
}

# Container health check (now uses docker-smart-status)
container_health() {
  echo "Container Runtime: $CONTAINER_RUNTIME"
  echo "Compose Command: $COMPOSE_COMMAND"
  echo ""
  docker-smart-status
  echo ""
  echo "Version Info:"
  if docker_is_running; then
    docker version --format '{{ "{{.Client.Version}}" }}'
    echo ""
    echo "Running Containers:"
    docker ps --format '{{ "table {{.Names}}\t{{.Status}}\t{{.Image}}" }}'
  else
    echo "Docker not running - use any docker command to auto-start"
  fi
}

# Export convenience aliases - now powered by docker-smart.zsh
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dlogs="docker logs"
alias dexec="docker exec -it"
alias dprune="container_prune"
alias dhealth="container_health"

# Dev container aliases
alias devbuild="container_dev_build"
alias devrun="container_dev_run"

# Smart Docker management aliases
alias docker-status="docker-smart-status"
alias docker-stop="docker-smart-stop"
alias docker-reset="docker-smart-reset"

# macOS container tips
container_tips() {
  echo "Smart Docker with Colima for macOS:"
  echo ""
  echo "✨ NEW: Intelligent auto-start and cleanup (like Rust's borrow system)"
  echo "• Docker commands auto-start Colima only when needed"
  echo "• Auto-stops after idle timeout (default: 10 minutes)"
  echo "• Respects running containers (won't stop if containers active)"
  echo "• Zero overhead when Docker not in use"
  echo ""
  echo "Smart Management:"
  echo "• docker-status     - Show smart Docker status"
  echo "• docker-stop       - Manually stop Colima"
  echo "• docker-reset      - Reset smart Docker state"
  echo ""
  echo "Configuration (set in ~/.zshrc):"
  echo "• DOCKER_IDLE_TIMEOUT=600      - Idle timeout in seconds"
  echo "• DOCKER_CLEANUP_AGGRESSIVE=true - Aggressive cleanup on stop"
  echo "• DOCKER_SMART_LOG_LEVEL=2     - Debug logging"
  echo ""
  echo "Legacy Functions:"
  echo "• container_dev_build, container_dev_run - Dev containers"
  echo "• container_prune - Manual cleanup"
  echo ""
  echo "Aliases:"
  echo "• d=docker, dc=docker compose, dps=docker ps"
  echo "• dlogs=docker logs, dexec=docker exec -it"
  echo "• dprune=cleanup, devbuild/devrun=dev containers"
}