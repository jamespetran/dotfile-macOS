#!/usr/bin/env bash
#
# Integration Feature Test Suite
# Tests container runtime, Rust development, and platform integration features
#
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Integration Feature Test Suite${NC}"
echo "================================"

# Test Container Runtime Integration
echo -e "\n${YELLOW}Container Runtime Integration:${NC}"

# Detect expected runtime
if [[ "$(uname -s)" == "Darwin" ]]; then
    RUNTIME="docker"
else
    RUNTIME="podman"
fi

# Test container commands if runtime is available
if command -v "$RUNTIME" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $RUNTIME is installed"
    
    # Test basic functionality
    if timeout 5 "$RUNTIME" --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $RUNTIME responds to commands"
        
        # Test hello-world if possible
        echo "  Testing container run..."
        if timeout 30 "$RUNTIME" run --rm hello-world >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Can run containers successfully"
        else
            echo -e "${YELLOW}⚠${NC} Container run test failed (may need to start daemon)"
        fi
    else
        echo -e "${RED}✗${NC} $RUNTIME not responding"
    fi
    
    # Check for compose
    if [[ "$RUNTIME" == "docker" ]]; then
        if docker compose version >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Docker Compose v2 available"
        elif command -v docker-compose >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠${NC} Legacy docker-compose found (consider upgrading)"
        else
            echo -e "${YELLOW}⚠${NC} Docker Compose not found"
        fi
    else
        if command -v podman-compose >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} podman-compose available"
        else
            echo -e "${YELLOW}⚠${NC} podman-compose not found"
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC} $RUNTIME not installed"
fi

# Test Rust Development Environment
echo -e "\n${YELLOW}Rust Development Environment:${NC}"

if command -v rustc >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Rust compiler installed: $(rustc --version)"
    
    # Test cargo
    if command -v cargo >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Cargo available: $(cargo --version)"
        
        # Test common cargo subcommands
        echo "  Testing cargo extensions..."
        for cmd in nextest watch edit; do
            if cargo help "$cmd" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} cargo-$cmd installed"
            else
                echo -e "  ${YELLOW}⚠${NC} cargo-$cmd not installed"
            fi
        done
        
        # Test sccache
        if command -v sccache >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} sccache installed"
            if [[ -n "${RUSTC_WRAPPER:-}" ]] && [[ "$RUSTC_WRAPPER" == "sccache" ]]; then
                echo -e "${GREEN}✓${NC} sccache configured as RUSTC_WRAPPER"
            else
                echo -e "${YELLOW}⚠${NC} sccache not configured as RUSTC_WRAPPER"
            fi
        else
            echo -e "${YELLOW}⚠${NC} sccache not installed"
        fi
    else
        echo -e "${RED}✗${NC} Cargo not found"
    fi
else
    echo -e "${YELLOW}⚠${NC} Rust not installed"
fi

# Test Platform Integration
echo -e "\n${YELLOW}Platform Integration:${NC}"

# Test shell functions
if [[ -n "$ZSH_VERSION" ]]; then
    echo "  Testing shell integration functions..."
    
    # Source integration files if available
    if [[ -f "$HOME/.oh-my-zsh/custom/platform-integration.zsh" ]]; then
        source "$HOME/.oh-my-zsh/custom/platform-integration.zsh" 2>/dev/null
        
        # Test key functions
        if type check_dependencies >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} check_dependencies function available"
        else
            echo -e "${RED}✗${NC} check_dependencies function not found"
        fi
        
        if type sysinfo >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} sysinfo function available"
        else
            echo -e "${RED}✗${NC} sysinfo function not found"
        fi
    else
        echo -e "${YELLOW}⚠${NC} platform-integration.zsh not found"
    fi
else
    echo -e "  Not running in zsh, skipping function tests"
fi

# Test Development Tool Integration
echo -e "\n${YELLOW}Development Tool Integration:${NC}"

# IntelliJ IDEA
if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ -d "/Applications/IntelliJ IDEA.app" ]]; then
        echo -e "${GREEN}✓${NC} IntelliJ IDEA found on macOS"
    else
        echo -e "  IntelliJ IDEA not installed"
    fi
else
    # Linux check
    IDEA_FOUND=false
    for pattern in "$HOME/.local/share/JetBrains/Toolbox/apps/IDEA-U/ch-0/*/bin/idea.sh" \
                   "/opt/idea/bin/idea.sh"; do
        if compgen -G "$pattern" >/dev/null 2>&1; then
            IDEA_FOUND=true
            break
        fi
    done
    
    if [[ "$IDEA_FOUND" == "true" ]]; then
        echo -e "${GREEN}✓${NC} IntelliJ IDEA found on Linux"
    else
        echo -e "  IntelliJ IDEA not installed"
    fi
fi

# VS Code
if command -v code >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} VS Code command line tool available"
else
    echo -e "  VS Code not found in PATH"
fi

echo -e "\n${BLUE}Integration tests complete!${NC}"