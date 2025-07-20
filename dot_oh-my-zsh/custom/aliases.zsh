# Simple chezmoi alias
alias cz='chezmoi'

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

# Rust (Performance-focused)
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo nextest run'  # Blazing fast tests
alias ctc='cargo test'        # Traditional cargo test if needed
alias cl='cargo clippy'
alias cf='cargo fmt'
alias cw='cargo watch -x check'
alias cn='cargo nextest run'  # Explicit nextest
alias cnw='cargo watch -x "nextest run"'  # Watch with nextest
alias cstats='sccache --show-stats'  # Cache statistics
alias csize='cargo bloat --release --crates'  # Binary size analysis

# zoxide (better cd)
eval "$(zoxide init zsh)"

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

# Claude Code CLI (remove alias if claude is in PATH)
# alias claude="claude"

# Zellij layouts
alias zdev='zellij --layout dev'
alias zmon='zellij --layout monitoring'
alias zrust='zellij --layout rust'
alias zai='zellij --layout ai-dev'

# Power user tool aliases
alias top='btop'
alias du='dust'
alias ps='procs'
alias sed='sd'
alias curl='xh'
alias http='xh'

# Just command runner aliases
alias j='just'
alias jd='just dev'
alias jt='just test'
alias jb='just build'
alias jr='just build-release'
alias jc='just check'
alias jf='just fmt'
alias jl='just clippy'

# GitHub CLI aliases
alias ghd='gh dash'
alias ghs='gh s'
alias ghpr='gh pr create --draft'
alias ghprl='gh pr list'
alias ghprv='gh pr view'
alias ghi='gh issue list'
alias ghr='gh repo view'

# File navigation and analysis
alias explore='broot'  # Interactive file exploration
alias nav='broot'      # Interactive navigation
alias br='broot'       # Short broot alias

# Dataset analysis shortcuts
alias analyze='dv'
alias datastat='dstats'
alias datafind='dfind'
alias datacheck='dcheck'
