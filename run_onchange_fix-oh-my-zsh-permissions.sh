#!/usr/bin/env bash
# Fix Oh My Zsh permissions to prevent Powerlevel10k warnings
# This script runs when the file changes

set -euo pipefail

echo "Fixing Oh My Zsh directory permissions..."

# Fix permissions on Oh My Zsh directories
if [ -d "$HOME/.oh-my-zsh" ]; then
    chmod 755 "$HOME/.oh-my-zsh"
    chmod -R 755 "$HOME/.oh-my-zsh/custom"
    
    # Fix any insecure completion directories
    if command -v compaudit >/dev/null 2>&1; then
        # Use platform-agnostic approach (xargs -r is GNU-specific)
        local insecure_dirs=$(compaudit 2>/dev/null)
        if [ -n "$insecure_dirs" ]; then
            echo "$insecure_dirs" | xargs chmod g-w,o-w || true
        fi
    fi
    
    echo "Oh My Zsh permissions fixed"
else
    echo "Oh My Zsh directory not found, skipping"
fi