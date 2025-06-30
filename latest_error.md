❯ cz apply
🔄  Updating development packages…
brew update … ✅
brew install/upgrade packages … ✅
Update zsh-autosuggestions … ✅
Update zsh-syntax-highlighting … ✅
Update Powerlevel10k theme … ✅
✅  Package updates complete.
🚀  Setting up developer environment (one-time setup)…
[sudo] password for james:
Layer 1: apt base packages … ✅
brew install core packages … ✅
Install Rust toolchain … ✅
Install Node (dnf/nvm) … ✅
Install Oh My Zsh framework … ✅
Install Bitwarden CLI (bw) … ✅
pipx bootstrap … ✅
pipx install poetry & HF Hub … ✅
Ensure zellij … ✅
Install zsh-autosuggestions … ✅
Install zsh-syntax-highlighting … ✅
Install Powerlevel10k theme … ✅
🎉  Developer environment setup complete.
🚀 Setting up advanced git tools...
📝 Configuring git aliases for advanced tools...
✅ Advanced git tools configured successfully!
💡 New commands available:
git absorb      - Automatically create fixup commits
git sl          - Smart log (git-branchless)
git sync        - Sync with upstream
git undo        - Undo recent changes
git lg/ll/ld/ls - Enhanced log formats
🔍 Setting up Atuin (encrypted shell history)...
✅ Atuin already configured. Skipping setup.
🌳 Setting up broot (intelligent file navigation)...
✅ broot setup complete!
💡 Usage:
br           - Launch broot file navigator
tree         - Same as br (alias)
explore      - Same as br (alias)

🔥 Power features:
:e <file>    - Edit file in ${EDITOR:-nvim}
:v <file>    - View file with bat
:a <file>    - Analyze dataset
:s <dir>     - Show directory stats
:gd <file>   - Git diff file
/pattern     - Search files
Alt+Enter    - cd to directory and exit
🔧 Checking git configuration...
✅ Git configuration already correct. Skipping.
🐙 Setting up GitHub CLI extensions...
📦 Installing GitHub CLI extensions...
Installing gh-release extension...
"release" matches the name of a built-in command or alias
Installing gh-dash (PR dashboard)...
✓ Installed extension dlvhdr/gh-dash
Installing gh-copilot extension...
✓ Installed extension github/gh-copilot
Installing gh-s (search extension)...
✓ Installed extension gennaro-tedesco/gh-s
⚙️  Configuring GitHub CLI...
✅ GitHub CLI setup complete!
💡 New commands available:
gh dash          - Interactive PR dashboard
gh s <term>      - Search repositories
gh copilot       - GitHub Copilot CLI

🔐 Run 'gh auth login' to authenticate with GitHub
🔧 Setting up mise (universal runtime manager)...
✅ mise already available. Configuring...
🐍 Installing Python 3.11 for AI/ML development...
📦 Installing Node.js LTS...
mise hint use multiple versions simultaneously with mise use python@3.12 python@3.11
mise ~/.config/mise/config.toml tools: python@3.11.13
mise ~/.config/mise/config.toml tools: node@22.17.0
🛠️  Installing global Python tools...
ERROR: Could not find an activated virtualenv (required).
chezmoi: setup-mise.sh: exit status 3
~/.local/share/chezmoi main !1                                                                                              1m 21s 11:11:07
❯ 
