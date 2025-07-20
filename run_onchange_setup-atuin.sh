#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Setting up Atuin (encrypted shell history)..."

# Check if atuin is installed
if ! command -v atuin >/dev/null 2>&1; then
  echo "⚠️  Atuin not found. Install with: brew install atuin"
  exit 1
fi

# Check if atuin is already configured (has a database)
if [ -f ~/.local/share/atuin/history.db ] || [ -f ~/.config/atuin/key ]; then
  echo "✅ Atuin already configured. Skipping setup."
  exit 0
fi

echo "📝 Initializing Atuin..."

# Initialize atuin (creates local database and encryption key)
atuin init

echo "🔑 Atuin has been initialized with local encryption."
echo "💡 To sync across machines:"
echo "   1. Create account: atuin register -u <email> -p <password>"
echo "   2. Login on other machines: atuin login -u <email> -p <password>"
echo "   3. Import existing history: atuin import auto"
echo ""
echo "✅ Atuin setup complete! Restart your shell to activate."