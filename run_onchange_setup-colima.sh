#!/usr/bin/env bash
#
# Setup Colima auto-start service
# Runs when this script changes to ensure Colima starts automatically

set -euo pipefail
IFS=$'\n\t'

echo "🐳 Setting up Colima auto-start service..."

# Check if Colima is installed
if ! command -v colima >/dev/null 2>&1; then
    echo "❌ Colima not found. Please run 'cz apply' first to install via brew."
    exit 1
fi

# Check if Docker CLI is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker CLI not found. Please run 'cz apply' first to install via brew."
    exit 1
fi

PLIST_FILE="$HOME/Library/LaunchAgents/com.colima.autostart.plist"

# Enable auto-start service
echo "🚀 Enabling Colima auto-start service..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo "✅ Colima will now auto-start on login and stay running"
echo ""
echo "🚀 Starting Colima now..."
if ! colima status >/dev/null 2>&1; then
    colima start 2>/dev/null || echo "Colima start failed, but service will handle it"
fi

echo ""
echo "✅ Docker setup complete! Colima will auto-start on login."