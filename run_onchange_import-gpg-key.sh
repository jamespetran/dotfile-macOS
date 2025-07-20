#!/usr/bin/env bash
set -euo pipefail

echo "🔑 Checking for GPG private key..."

GPG_KEY_ID="AC9715E1C25B4B8A" # Paste your GPG Key ID here

# Check if the secret key is already imported
if gpg --list-secret-keys | grep -q "$GPG_KEY_ID"; then
  echo "✅ GPG key $GPG_KEY_ID already imported. Skipping."
  exit 0
fi

echo "Importing GPG private key from Bitwarden..."
# Fetch the secure note from Bitwarden and import it
bw get notes "GPG Private Key" | gpg --import

echo "Trusting the newly imported GPG key..."
# This command tells gpg to ultimately trust your key so you don't get prompted
echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key "$GPG_KEY_ID" trust

echo "✅ GPG key imported and trusted successfully."