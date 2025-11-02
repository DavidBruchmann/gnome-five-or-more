#!/bin/bash

# Simple Debug Panel Launcher for Five or More
# This script provides easy access to the debug panel

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Five or More - Debug Panel Launcher"
echo "===================================="
echo ""
echo "Building project..."

cd "$SCRIPT_DIR/builddir"
if ! ninja; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Starting Five or More with Debug Panel instructions..."
echo ""
echo "🔧 DEBUG PANEL CONTROLS:"
echo "   F12          - Toggle debug panel on/off"
echo "   Menu > Debug - Access via hamburger menu"
echo "   Click cells  - Inspect line detection"
echo ""
echo "📊 DEBUG FEATURES:"
echo "   • Coordinate system validation"
echo "   • Traditional vs composite line comparison"  
echo "   • Phantom line detection warnings"
echo "   • Real-time monitoring toggle"
echo "   • Debug log with export"
echo ""
echo "Press F12 immediately after the game starts to show the debug panel!"
echo ""

# Set up GSettings schema path for development build
export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/builddir/data/schemas"

# Run the game
exec "$SCRIPT_DIR/builddir/src/five-or-more"