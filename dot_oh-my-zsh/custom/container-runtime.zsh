# Container Runtime Integration for macOS
# Colima (lightweight Docker) configuration

# macOS - Using Colima + Docker CLI
export CONTAINER_RUNTIME="docker"
export COMPOSE_COMMAND="docker compose"

# Docker settings
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Colima auto-recovery settings
export COLIMA_AUTO_START=true
export COLIMA_RECOVERY_TIMEOUT=30

# Check if Colima/Docker is running
docker_status() {
  if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    echo "Docker (via Colima) is running"
    return 0
  else
    echo "Docker (via Colima) is not running"
    return 1
  fi
}

# Auto-start Colima with recovery
docker_start() {
  if ! command -v colima &>/dev/null; then
    echo "Colima not found. Installing via brew..."
    brew install colima docker
    return $?
  fi

  # Check if already running
  if docker info &>/dev/null 2>&1; then
    echo "Docker is already running"
    return 0
  fi

  echo "Starting Colima..."
  
  # Start with optimized settings for development
  if ! colima start --cpu 4 --memory 8 --disk 100 --vm-type vz --vz-rosetta --network-address --dns 1.1.1.1,8.8.8.8 2>/dev/null; then
    echo "Failed to start Colima with VZ, trying QEMU..."
    colima start --cpu 4 --memory 8 --disk 100 --vm-type qemu --network-address --dns 1.1.1.1,8.8.8.8
  fi

  # Wait for Docker to be ready with timeout
  local count=0
  while ! docker info &>/dev/null && [ $count -lt $COLIMA_RECOVERY_TIMEOUT ]; do
    sleep 2
    count=$((count + 1))
    echo -n "."
  done
  echo ""

  if docker info &>/dev/null; then
    echo "Docker (via Colima) is ready"
    return 0
  else
    echo "Docker (via Colima) failed to start within ${COLIMA_RECOVERY_TIMEOUT}s"
    return 1
  fi
}

# Auto-recovery function (called by container commands)
docker_ensure_running() {
  if ! docker info &>/dev/null 2>&1; then
    echo "Docker not responding, attempting auto-recovery..."
    docker_start
  fi
}

# Universal container functions with auto-recovery
container_run() {
  docker_ensure_running && $CONTAINER_RUNTIME run "$@"
}

container_build() {
  docker_ensure_running && $CONTAINER_RUNTIME build "$@"
}

container_exec() {
  docker_ensure_running && $CONTAINER_RUNTIME exec "$@"
}

container_ps() {
  docker_ensure_running && $CONTAINER_RUNTIME ps "$@"
}

container_images() {
  docker_ensure_running && $CONTAINER_RUNTIME images "$@"
}

container_logs() {
  docker_ensure_running && $CONTAINER_RUNTIME logs "$@"
}

# Compose shortcuts with auto-recovery
compose_up() {
  docker_ensure_running && $COMPOSE_COMMAND up "$@"
}

compose_down() {
  docker_ensure_running && $COMPOSE_COMMAND down "$@"
}

compose_build() {
  docker_ensure_running && $COMPOSE_COMMAND build "$@"
}

compose_logs() {
  docker_ensure_running && $COMPOSE_COMMAND logs "$@"
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
  echo "Colima Docker Tips for macOS:"
  echo ""
  echo "• Colima provides lightweight Docker without Docker Desktop"
  echo "• Auto-starts when you use any container command"
  echo "• Use 'docker_start' to manually start Colima"
  echo "• Use 'colima stop' to stop the VM"
  echo "• Resource limits: 4 CPU, 8GB RAM, 100GB disk"
  echo ""
  echo "Useful commands:"
  echo "• container_run, container_build, container_exec (with auto-recovery)"
  echo "• compose_up, compose_down, compose_build (with auto-recovery)"
  echo "• container_dev_build, container_dev_run"
  echo "• dhealth - check container runtime status"
  echo ""
  echo "Aliases:"
  echo "• d=docker, dc=docker compose, dps=docker ps"
  echo "• dlogs=docker logs, dexec=docker exec -it"
  echo "• dprune=cleanup, devbuild/devrun=dev containers"
}