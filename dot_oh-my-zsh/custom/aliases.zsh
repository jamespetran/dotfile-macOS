# Simple chezmoi alias - scripts handle their own Bitwarden authentication
alias cz='chezmoi'

# Modern replacements
alias ls='eza --icons'
alias cat='bat'
alias find='fd'

# Git
alias g='git'
alias gst='git status'
alias gcm='git commit -m'
alias gaa='git add .'
alias gb='git branch'
alias gco='git checkout'
alias glg='git log --oneline --decorate --graph --all'
alias gcl='git clone'

# Advanced git aliases
alias gsl='git sl'           # git-branchless smartlog
alias gabs='git absorb'      # git-absorb
alias gundo='git undo'       # git-branchless undo
alias gsync='git sync'       # git-branchless sync
alias glgg='git lg'          # enhanced log
alias gdiff='git diff --word-diff=color'
alias gshow='git show --word-diff=color'

# Rust
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cl='cargo clippy'
alias cf='cargo fmt'
alias cw='cargo watch -x check'

# zoxide (better cd)
eval "$(zoxide init zsh)"

# App launchers
alias idea='/home/james/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea'

# Docker/Podman smart aliasing
if command -v podman &> /dev/null && grep -q silverblue /etc/os-release 2>/dev/null; then
  alias d='podman'
  alias dps='podman ps'
  alias dcu='podman-compose up'
  alias dcd='podman-compose down'
else
  alias d='docker'
  alias dps='docker ps'
  alias dcu='docker compose up'
  alias dcd='docker compose down'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# Coding helpers
alias k='kubectl'
alias python='python3'
alias pip='pip3'
alias serve='python3 -m http.server 8000'
alias ports='ss -tulpn'
alias grep='grep --color=auto'

alias cls='clear && printf "\e[3J"'

# Claude Code CLI
alias claude="~/.claude/local/claude"

# Zellij layouts
alias zdev='zellij --layout dev'
alias zmon='zellij --layout monitoring'
alias zrust='zellij --layout rust'

# Power user tool aliases
alias top='btop'
alias du='dust'
alias ps='procs'
alias sed='sd'
alias curl='xh'
alias http='xh'
