# macOS-specific aliases and configurations
# This file is only sourced on macOS systems

# GNU coreutils aliases (if installed via Homebrew)
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
  # Add GNU bin to PATH for direct access
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  
  # Create aliases for common commands
  alias ls='gls --color=auto'
  alias dir='gdir --color=auto'
  alias vdir='gvdir --color=auto'
  alias grep='ggrep --color=auto'
  alias fgrep='gfgrep --color=auto'
  alias egrep='gegrep --color=auto'
else
  # Fallback to BSD versions with compatible flags
  alias ls='ls -G'  # -G enables color on BSD ls
fi

# Docker Desktop is the standard container runtime on macOS
# No additional aliases needed

# macOS-specific utilities
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias flushdns='sudo dscacheutil -flushcache'

# Quick Look from terminal
alias ql='qlmanage -p'

# Get macOS version
alias macosversion='sw_vers -productVersion'

# Homebrew maintenance
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewdeps='brew deps --tree --installed'

# Fix the broken mac_aliases.sh reference
# This file replaces the missing ~/dotfiles/scripts/mac_aliases.sh