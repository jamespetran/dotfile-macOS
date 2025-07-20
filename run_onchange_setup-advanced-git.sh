#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up advanced git tools..."

# Check if git-absorb is installed
if ! command -v git-absorb >/dev/null 2>&1; then
  echo "⚠️  git-absorb not found. Install with: brew install git-absorb"
  exit 1
fi

# Check if git-branchless is installed  
if ! command -v git-branchless >/dev/null 2>&1; then
  echo "⚠️  git-branchless not found. Install with: brew install git-branchless"
  exit 1
fi

echo "📝 Configuring git aliases for advanced tools..."

# Set up git-absorb alias
git config --global alias.absorb '!git-absorb'

# Set up git-branchless aliases
git config --global alias.sl 'smartlog'
git config --global alias.sync 'sync'
git config --global alias.undo 'undo'
git config --global alias.reword 'reword'

# Enhanced git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Advanced git log aliases
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.ll "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --numstat"
git config --global alias.ld "log --pretty=format:'%C(yellow)%h\\ %C(green)%ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --date=short --graph"
git config --global alias.ls "log --pretty=format:'%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --date=relative"

# Diff and merge tool configuration
git config --global diff.tool delta
git config --global merge.tool vimdiff
git config --global difftool.prompt false
git config --global mergetool.prompt false

# Advanced git settings
git config --global push.default simple
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global branch.autosetupmerge always
git config --global branch.autosetuprebase always

# Git absorb configuration
git config --global absorb.maxStack 50

echo "✅ Advanced git tools configured successfully!"
echo "💡 New commands available:"
echo "   git absorb      - Automatically create fixup commits"
echo "   git sl          - Smart log (git-branchless)"
echo "   git sync        - Sync with upstream"
echo "   git undo        - Undo recent changes"
echo "   git lg/ll/ld/ls - Enhanced log formats"