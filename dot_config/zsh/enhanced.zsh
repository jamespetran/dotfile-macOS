# Enhanced Zsh Configuration for Power Users
# This file contains advanced zsh settings for improved performance and usability

# History Configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Advanced History Options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
setopt HIST_VERIFY               # Don't execute immediately upon history expansion

# Completion System Enhancements
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select=2
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# Advanced completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# Git completion performance
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-log:*' tag-order 'heads:-branch:branch refs'

# Directory Navigation
setopt AUTO_CD              # Auto change to a directory without typing cd
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd
setopt CDABLE_VARS          # Change directory to a path stored in a variable
setopt MULTIOS              # Write to multiple descriptors

# Globbing
setopt EXTENDED_GLOB        # Use extended globbing syntax
setopt NOMATCH              # If a pattern has no matches, leave it unchanged
setopt GLOB_DOTS            # Do not require a leading '.' in a filename to be matched explicitly

# Job Control
setopt LONG_LIST_JOBS       # List jobs in the long format by default
setopt AUTO_RESUME          # Attempt to resume existing job before creating a new process
setopt NOTIFY               # Report status of background jobs immediately
setopt BG_NICE              # Run all background jobs at a lower priority
setopt HUP                  # Send the HUP signal to running jobs when the shell exits

# Input/Output
setopt CORRECT              # Try to correct the spelling of commands
setopt INTERACTIVE_COMMENTS # Allow comments even in interactive shells
setopt HASH_CMDS            # Hash commands as they are executed
setopt HASH_DIRS            # Hash directories as they are referenced

# Performance Optimizations
# Skip global compinit for faster startup
skip_global_compinit=1

# Load completion system with optimizations
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Advanced Key Bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[3~' delete-char         # Delete key
bindkey '^[[H' beginning-of-line    # Home key
bindkey '^[[F' end-of-line          # End key

# Custom Functions
# Smart extract function
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and cd to directory
fcd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# Advanced git functions
gfco() {
    git branch -a --sort=-committerdate | grep -v HEAD | sed 's/^[* ] //' | sed 's/remotes\/[^/]*\///' | sort -u | fzf | xargs git checkout
}

# Process finder with fzf
fps() {
    ps aux | fzf --header-lines=1 --info=inline --layout=reverse --multi | awk '{print $2}'
}

# Kill process with fzf
fkill() {
    local pids
    pids=$(ps aux | fzf --header-lines=1 --info=inline --layout=reverse --multi | awk '{print $2}')
    if [[ -n $pids ]]; then
        echo "$pids" | xargs kill -"${1:-9}"
    fi
}

# Rust local development optimizations
export CARGO_INCREMENTAL=1
export RUST_BACKTRACE=1

# Build parallelization (use all cores)
export MAKEFLAGS="-j$(nproc)"
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"

# Faster linking with lld
export RUSTFLAGS="-C link-arg=-fuse-ld=lld"

# Load dataset analysis tools
[[ -f ~/.config/zsh/dataset-tools.zsh ]] && source ~/.config/zsh/dataset-tools.zsh

# Load notification system
[[ -f ~/.config/zsh/notifications.zsh ]] && source ~/.config/zsh/notifications.zsh