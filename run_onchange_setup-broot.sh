#!/usr/bin/env bash
set -euo pipefail

echo "🌳 Setting up broot (intelligent file navigation)..."

# Check if broot is installed
if ! command -v broot >/dev/null 2>&1; then
  echo "⚠️  broot not found. Install with: brew install broot"
  exit 1
fi

# Initialize broot if not already done
if [ ! -f ~/.config/broot/launcher/bash/br ]; then
  echo "🚀 Initializing broot..."
  mkdir -p ~/.config/broot/launcher/{bash,zsh}
  broot --print-shell-function bash > ~/.config/broot/launcher/bash/br
  broot --print-shell-function zsh > ~/.config/broot/launcher/zsh/br
fi

echo "✅ broot setup complete!"
echo "💡 Usage:"
echo "   br           - Launch broot file navigator"
echo "   tree         - Same as br (alias)"
echo "   explore      - Same as br (alias)"
echo ""
echo "🔥 Power features:"
echo "   :e <file>    - Edit file in \${EDITOR:-nvim}"
echo "   :v <file>    - View file with bat"
echo "   :a <file>    - Analyze dataset"
echo "   :s <dir>     - Show directory stats"
echo "   :gd <file>   - Git diff file"
echo "   /pattern     - Search files"
echo "   Alt+Enter    - cd to directory and exit"