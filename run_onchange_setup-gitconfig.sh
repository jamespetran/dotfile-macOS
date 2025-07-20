#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Checking git configuration..."

# Target configuration values (fetch email from Bitwarden only if needed)
TARGET_NAME="jamespetran"
TARGET_SIGNING_KEY="21D39CC1D0B3B44A"

# Check current git config
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_SIGNING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")
CURRENT_GPG_SIGN=$(git config --global commit.gpgsign 2>/dev/null || echo "")

# Quick check if non-email settings are already correct
if [ "$CURRENT_NAME" = "$TARGET_NAME" ] && \
   [ "$CURRENT_SIGNING_KEY" = "$TARGET_SIGNING_KEY" ] && \
   [ "$CURRENT_GPG_SIGN" = "true" ] && \
   [ -n "$CURRENT_EMAIL" ]; then
  echo "✅ Git configuration already correct. Skipping."
  exit 0
fi

# Only fetch email from Bitwarden if we need to make changes
TARGET_EMAIL=$(bw get item "github.com" | jq -r '.fields[] | select(.name == "noreply_email") | .value')

# Final check with email from Bitwarden
if [ "$CURRENT_EMAIL" = "$TARGET_EMAIL" ] && \
   [ "$CURRENT_NAME" = "$TARGET_NAME" ] && \
   [ "$CURRENT_SIGNING_KEY" = "$TARGET_SIGNING_KEY" ] && \
   [ "$CURRENT_GPG_SIGN" = "true" ]; then
  echo "✅ Git configuration already correct. Skipping."
  exit 0
fi

echo "📝 Updating git configuration..."

# Set user information
if [ "$CURRENT_NAME" != "$TARGET_NAME" ]; then
  git config --global user.name "$TARGET_NAME"
  echo "  ✓ Set user.name to $TARGET_NAME"
fi

if [ "$CURRENT_EMAIL" != "$TARGET_EMAIL" ]; then
  git config --global user.email "$TARGET_EMAIL"
  echo "  ✓ Set user.email to $TARGET_EMAIL"
fi

# Set GPG signing
if [ "$CURRENT_SIGNING_KEY" != "$TARGET_SIGNING_KEY" ]; then
  git config --global user.signingkey "$TARGET_SIGNING_KEY"
  echo "  ✓ Set signing key to $TARGET_SIGNING_KEY"
fi

if [ "$CURRENT_GPG_SIGN" != "true" ]; then
  git config --global commit.gpgsign true
  echo "  ✓ Enabled GPG signing for commits"
fi

echo "✅ Git configuration updated successfully."