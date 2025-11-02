#!/bin/bash

# Five or More - Development Runner Script
# This script sets up the proper environment to run Five or More from the installed version

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Five or More - Development Version"
echo "=================================="
echo ""
echo "Game Info Panel Available:"
echo "- Click the (i) button in headerbar to toggle info panel"
echo "- Or use Menu > Game Info"
echo "- Click on board cells to inspect position details"
echo ""
echo "For automatic info panel, use: ./launch-debug-panel-safe.sh"
echo ""

# Set up the environment to use the installed version
export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/install-root/usr/local/share/glib-2.0/schemas"

# Run the application from the installed location
exec "$SCRIPT_DIR/install-root/usr/local/bin/five-or-more" "$@"