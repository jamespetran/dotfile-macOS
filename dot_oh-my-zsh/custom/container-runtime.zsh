# Container Runtime Integration for macOS
# Docker Desktop configuration

# macOS - Using Docker Desktop
export CONTAINER_RUNTIME="docker"
export COMPOSE_COMMAND="docker compose"

# Docker Desktop specific settings
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Check if Docker Desktop is running
docker_status() {
  if command -v docker &>/dev/null && docker info &>/dev/null; then
    echo "Docker Desktop is running"
    return 0
  else
    echo "Docker Desktop is not running"
    return 1
  fi
}

# Start Docker Desktop on macOS
docker_start() {
  if [[ -d "/Applications/Docker.app" ]]; then
    open -a Docker
    echo "Starting Docker Desktop..."
    # Wait for Docker to be ready
    local count=0
    while ! docker info &>/dev/null && [ $count -lt 30 ]; do
      sleep 2
      count=$((count + 1))
    done
    if docker info &>/dev/null; then
      echo "Docker Desktop is ready"
    else
      echo "Docker Desktop failed to start"
      return 1
    fi
  else
    echo "Docker Desktop not found. Please install from https://www.docker.com/products/docker-desktop"
    return 1
  fi
}

# Universal container functions
container_run() {
  $CONTAINER_RUNTIME run "$@"
}

container_build() {
  $CONTAINER_RUNTIME build "$@"
}

container_exec() {
  $CONTAINER_RUNTIME exec "$@"
}

container_ps() {
  $CONTAINER_RUNTIME ps "$@"
}

container_images() {
  $CONTAINER_RUNTIME images "$@"
}

container_logs() {
  $CONTAINER_RUNTIME logs "$@"
}

# Compose shortcuts
compose_up() {
  $COMPOSE_COMMAND up "$@"
}

compose_down() {
  $COMPOSE_COMMAND down "$@"
}

compose_build() {
  $COMPOSE_COMMAND build "$@"
}

compose_logs() {
  $COMPOSE_COMMAND logs "$@"
}

# Development container helpers
container_dev_build() {
  local name="${1:-dev}"
  local dockerfile="${2:-Dockerfile}"
  $CONTAINER_RUNTIME build -t "$name" -f "$dockerfile" .
}

container_dev_run() {
  local name="${1:-dev}"
  shift
  $CONTAINER_RUNTIME run -it --rm \
    -v "$PWD:/workspace" \
    -w /workspace \
    --name "${name}-container" \
    "$name" "$@"
}

# Cleanup functions
container_prune() {
  echo "Pruning stopped containers..."
  $CONTAINER_RUNTIME container prune -f
  echo "Pruning unused images..."
  $CONTAINER_RUNTIME image prune -f
  echo "Pruning unused volumes..."
  $CONTAINER_RUNTIME volume prune -f
  echo "Cleanup complete!"
}

# Container health check
container_health() {
  echo "Container Runtime: $CONTAINER_RUNTIME"
  echo "Compose Command: $COMPOSE_COMMAND"
  echo ""
  docker_status
  echo ""
  echo "Version Info:"
  $CONTAINER_RUNTIME version --format '{{ "{{.Client.Version}}" }}'
  echo ""
  echo "Running Containers:"
  $CONTAINER_RUNTIME ps --format '{{ "table {{.Names}}\t{{.Status}}\t{{.Image}}" }}'
}

# Export convenience aliases
alias d="$CONTAINER_RUNTIME"
alias dc="$COMPOSE_COMMAND"
alias dps="container_ps"
alias dlogs="container_logs"
alias dexec="container_exec -it"
alias dprune="container_prune"
alias dhealth="container_health"

# Dev container aliases
alias devbuild="container_dev_build"
alias devrun="container_dev_run"

# macOS container tips
container_tips() {
  echo "Docker Desktop Tips for macOS:"
  echo ""
  echo "• Docker Desktop manages the Docker daemon automatically"
  echo "• Use 'docker_start' to launch Docker Desktop from terminal"
  echo "• Resource limits can be configured in Docker Desktop preferences"
  echo "• Docker Desktop includes Kubernetes (can be enabled in settings)"
  echo ""
  echo "Useful commands:"
  echo "• container_run, container_build, container_exec"
  echo "• compose_up, compose_down, compose_build"
  echo "• container_dev_build, container_dev_run"
}