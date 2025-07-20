#!/usr/bin/env bash
# Test script for Phase 4: Integration & Enhancement

set -euo pipefail

echo "=== Phase 4 Integration Test ==="
echo

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
tests_failed=0

# Test function
test_feature() {
    local name="$1"
    local command="$2"
    
    echo -n "Testing $name... "
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        ((tests_passed++))
    else
        echo -e "${RED}✗${NC}"
        ((tests_failed++))
    fi
}

# 1. Test template files exist
echo "1. Checking new template files:"
test_feature "container-runtime.zsh.tmpl" "[[ -f dot_oh-my-zsh/custom/container-runtime.zsh.tmpl ]]"
test_feature "rust-dev.zsh.tmpl" "[[ -f dot_oh-my-zsh/custom/rust-dev.zsh.tmpl ]]"
test_feature "platform-integration.zsh.tmpl" "[[ -f dot_oh-my-zsh/custom/platform-integration.zsh.tmpl ]]"
test_feature "aliases.zsh.tmpl renamed" "[[ -f dot_oh-my-zsh/custom/aliases.zsh.tmpl ]]"
echo

# 2. Test chezmoidata.yaml contains required settings
echo "2. Checking .chezmoidata.yaml configuration:"
test_feature "containerRuntime variable" "grep -q 'containerRuntime:' .chezmoidata.yaml"
test_feature "intellijPath variable" "grep -q 'intellijPath:' .chezmoidata.yaml"
test_feature "rust.cargoAliases" "grep -q 'cargoAliases:' .chezmoidata.yaml"
test_feature "rust.enableSccache" "grep -q 'enableSccache:' .chezmoidata.yaml"
echo

# 3. Test integration in dot_zshrc
echo "3. Checking dot_zshrc integration:"
test_feature "platform-integration source" "grep -q 'platform-integration.zsh' dot_zshrc"
test_feature "container-runtime source" "grep -q 'container-runtime.zsh' dot_zshrc"
test_feature "rust-dev source" "grep -q 'rust-dev.zsh' dot_zshrc"
echo

# 4. Test template syntax
echo "4. Validating template syntax:"
test_feature "container runtime conditionals" "grep -q '{{- if eq .containerRuntime' dot_oh-my-zsh/custom/container-runtime.zsh.tmpl"
test_feature "rust config variables" "grep -q '{{- if .rust.' dot_oh-my-zsh/custom/rust-dev.zsh.tmpl"
test_feature "platform detection" "grep -q '{{ .chezmoi.os }}' dot_oh-my-zsh/custom/platform-integration.zsh.tmpl"
echo

# 5. Test fixed references
echo "5. Checking fixed references:"
test_feature "No mac_aliases.sh reference" "! grep -r 'mac_aliases.sh' . --exclude-dir=.git"
test_feature "macos-aliases.zsh reference exists" "grep -q 'macos-aliases.zsh' dot_oh-my-zsh/custom/aliases.zsh.tmpl"
echo

# 6. Test README updates
echo "6. Checking README documentation:"
test_feature "Phase 4 marked complete" "grep -q 'Phase 4 Complete' README.md"
test_feature "Container runtime documented" "grep -q 'Container Runtime Abstraction' README.md"
test_feature "Rust enhancement documented" "grep -q 'Rust Development Enhancement' README.md"
echo

# Summary
echo "=== Test Summary ==="
echo -e "Tests passed: ${GREEN}$tests_passed${NC}"
echo -e "Tests failed: ${RED}$tests_failed${NC}"

if [[ $tests_failed -eq 0 ]]; then
    echo -e "\n${GREEN}✅ All Phase 4 integration tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please review the output above.${NC}"
    exit 1
fi