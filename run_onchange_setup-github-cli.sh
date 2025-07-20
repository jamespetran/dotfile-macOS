#!/usr/bin/env bash
set -euo pipefail

echo "🐙 Setting up GitHub CLI extensions..."

# Check if gh is installed
if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️  GitHub CLI not found. Install with: brew install gh"
  exit 1
fi

# Install useful GitHub CLI extensions
echo "📦 Installing GitHub CLI extensions..."

# Extension for creating releases
if ! gh extension list | grep -q "github/gh-release"; then
  echo "Installing gh-release extension..."
  gh extension install github/gh-release || true
fi

# Extension for managing pull requests
if ! gh extension list | grep -q "dlvhdr/gh-dash"; then
  echo "Installing gh-dash (PR dashboard)..."
  gh extension install dlvhdr/gh-dash || true
fi

# Extension for better repository browsing
if ! gh extension list | grep -q "github/gh-copilot"; then
  echo "Installing gh-copilot extension..."
  gh extension install github/gh-copilot || true
fi

# Extension for Rust-specific workflows
if ! gh extension list | grep -q "gennaro-tedesco/gh-s"; then
  echo "Installing gh-s (search extension)..."
  gh extension install gennaro-tedesco/gh-s || true
fi

# Configure GitHub CLI for better defaults
echo "⚙️  Configuring GitHub CLI..."

# Set preferred editor
gh config set editor "nvim"

# Set preferred protocol
gh config set git_protocol "ssh"

# Set default branch behavior
gh config set prompt "enabled"

# Set pager
gh config set pager "bat"

echo "✅ GitHub CLI setup complete!"
echo "💡 New commands available:"
echo "   gh dash          - Interactive PR dashboard"
echo "   gh s <term>      - Search repositories"
echo "   gh copilot       - GitHub Copilot CLI"
echo ""
echo "🔐 Run 'gh auth login' to authenticate with GitHub"