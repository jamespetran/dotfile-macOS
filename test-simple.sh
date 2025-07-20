#!/bin/bash
set -euo pipefail

echo "🧪 Simple Setup Validation"

# Test 1: Essential tools
echo "Testing essential tools..."
for tool in git curl zsh podman; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(which "$tool")"
    else
        echo "  ❌ $tool: MISSING"
    fi
done

# Test 2: Modern CLI tools
echo -e "\nTesting modern CLI tools..."
for tool in rg bat fzf fd lazygit gh zellij atuin broot jq yq; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(which "$tool")"
    else
        echo "  ❌ $tool: MISSING"
    fi
done

# Test 2b: Infrastructure & DevOps tools (2025 focus)
echo -e "\nTesting Infrastructure & DevOps tools"
for tool in terraform tflint terraform-docs terragrunt infracost tenv checkov trivy; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(which "$tool")"
    else
        echo "  ⚠️  $tool: PENDING (install with: brew install $tool)"
    fi
done

# Test 3: Host language runtimes (should be available)
echo -e "\nTesting host language runtimes..."
for tool in python python3 node cargo; do
    if command -v "$tool" >/dev/null 2>&1; then
        tool_path=$(which "$tool")
        echo "  ✅ $tool: $tool_path"
    else
        echo "  ⚠️  $tool: ABSENT"
    fi
done

# Test 4: Package manager functionality
echo -e "\nTesting package managers..."
if command -v mise >/dev/null 2>&1; then
    echo "  ✅ mise: $(which mise)"
    mise list 2>/dev/null | head -3 | sed 's/^/    /' || echo "    No mise runtimes installed"
else
    echo "  ⚠️  mise: MISSING"
fi

if command -v brew >/dev/null 2>&1; then
    echo "  ✅ Homebrew: $(which brew)"
else
    echo "  ⚠️  Homebrew: MISSING"
fi

# Test 5: Container runtime
echo -e "\nTesting container runtime..."
if command -v podman >/dev/null 2>&1; then
    echo "  ✅ Podman available: $(podman --version 2>/dev/null || echo 'version check failed')"
    
    if timeout 10 podman run --rm hello-world >/dev/null 2>&1; then
        echo "  ✅ Podman functional: Can run containers"
    else
        echo "  ⚠️  Podman present but container test failed"
    fi
else
    echo "  ❌ Podman missing"
fi

echo -e "\n🎯 Setup Validation Complete!"