#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Setting up mise for host development..."

# Check if mise is installed
if ! command -v mise >/dev/null 2>&1; then
  echo "⚠️  mise not found. Install with: brew install mise"
  exit 1
fi

echo "✅ mise available. Installing language runtimes for host development..."

# Install Python for AI/ML and general development
echo "🐍 Installing Python 3.11 for AI/ML development..."
if mise list python 2>/dev/null | grep -q "(missing)" || ! mise list python 2>/dev/null | grep -q "3.11"; then
  mise install python@3.11
fi

# Install Node.js for tooling and web development  
echo "📦 Installing Node.js LTS for tooling..."
if mise list node 2>/dev/null | grep -q "(missing)" || ! mise list node 2>/dev/null | grep -q "lts"; then
  mise install node@lts
fi

# Set as global defaults
mise use --global python@3.11
mise use --global node@lts

# Install essential Python tools globally
# NOTE: This is where the original error occurred
# Fixed by not requiring virtualenv for global tool installation
echo "🛠️  Installing essential Python tools..."

# Use the mise-managed Python to install pipx (but without --user to avoid conflicts)
if ! command -v pipx >/dev/null 2>&1; then
  # Find mise-managed Python in a cross-platform way
  MISE_PYTHON=$(mise which python 2>/dev/null || true)
  
  if [ -n "$MISE_PYTHON" ] && [ -f "$MISE_PYTHON" ]; then
    echo "Installing pipx using mise-managed Python..."
    $MISE_PYTHON -m pip install pipx
    $MISE_PYTHON -m pipx ensurepath
  else
    echo "⚠️  Mise-managed Python not found, using system python3..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
  fi
fi

# Install useful global tools via pipx (isolated environments)
echo "📦 Installing Python development tools via pipx..."
if command -v pipx >/dev/null 2>&1; then
  # These tools are commonly needed globally
  pipx install black || true
  pipx install flake8 || true
  pipx install poetry || true
else
  echo "⚠️  pipx not available, skipping Python tool installation"
fi

# Install useful global Node.js tools
echo "📦 Installing essential Node.js tools..."
if command -v npm >/dev/null 2>&1; then
  # Global CLI tools that are useful everywhere
  npm install -g typescript || true
  npm install -g @types/node || true
  npm install -g nodemon || true
else
  echo "⚠️  npm not available, skipping Node.js tool installation"
fi

echo "✅ Host development setup complete!"
echo ""
echo "🎯 Available runtimes:"
mise list || true
echo ""
echo "💡 Language tools available on host:"
echo "  Python: $(python --version 2>/dev/null || echo 'not in PATH')"
echo "  Node.js: $(node --version 2>/dev/null || echo 'not in PATH')"
echo "  npm: $(npm --version 2>/dev/null || echo 'not in PATH')"
echo "  pipx: $(pipx --version 2>/dev/null || echo 'not installed')"
echo ""
echo "💡 All language tools ready for host development"