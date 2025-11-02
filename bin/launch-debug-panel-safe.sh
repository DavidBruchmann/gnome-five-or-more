#!/bin/bash

# Safe Debug Panel Launcher for Five or More
# This script uses the installed version which is more stable

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Five or More - Game Info Panel Launcher"
echo "========================================"
echo ""

# Check if installed version exists
if [ ! -f "$SCRIPT_DIR/install-root/usr/local/bin/five-or-more" ]; then
    echo "❌ Installed version not found!"
    echo "Please run: meson install -C builddir --destdir=install-root"
    echo ""
    echo "Attempting to use development build instead..."
    
    # Build the project first
    echo "Building project..."
    cd "$SCRIPT_DIR/builddir"
    if ! ninja; then
        echo "Build failed!"
        exit 1
    fi
    
    # Set up environment for development build
    export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/builddir/data/schemas"
    export XDG_DATA_DIRS="$SCRIPT_DIR/builddir/data:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    
    echo ""
    echo "⚠️  Using development build (may be unstable)"
    echo ""
    GAME_BINARY="$SCRIPT_DIR/builddir/src/five-or-more"
else
    echo "✓ Using stable installed version"
    echo ""
    
    # Set up environment for installed version
    export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/install-root/usr/local/share/glib-2.0/schemas"
    export XDG_DATA_DIRS="$SCRIPT_DIR/install-root/usr/local/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    
    GAME_BINARY="$SCRIPT_DIR/install-root/usr/local/bin/five-or-more"
fi

echo "🔧 GAME INFO PANEL CONTROLS:"
echo "   Info Button   - Click the (i) button in headerbar"
echo "   Menu > Game Info - Access via hamburger menu"
echo "   Click cells   - Inspect position details"
echo ""
echo "📊 PANEL FEATURES:"
echo "   • Game settings and board information"
echo "   • Position details and line analysis"  
echo "   • System alerts and technical details"
echo "   • Live updates toggle"
echo "   • Activity log with export"
echo ""
echo "🚀 Starting game..."
echo "   Click the (i) button in the headerbar to show the info panel!"
echo ""

# Run the game
exec "$GAME_BINARY"