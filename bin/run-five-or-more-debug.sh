#!/bin/bash

# Five or More - Debug Development Runner Script
# This script runs Five or More with the debug panel automatically enabled

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting Five or More with Debug Panel..."
echo "Debug Panel Controls:"
echo "- F12: Toggle debug panel visibility"
echo "- Click on board cells to inspect line detection"
echo "- Use hamburger menu > Debug Panel to toggle"
echo ""

# Build the project first
echo "Building project..."
cd "$SCRIPT_DIR/builddir"
if ! ninja; then
    echo "Build failed! Please fix compilation errors."
    exit 1
fi

echo "Starting game with debug panel..."
echo ""

# Set up environment for development
export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/builddir/data/schemas"

# Create a temporary script that will automatically show the debug panel
# We'll use a small wrapper that sends the F12 key after the game starts
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash

# Start the game in background
"$1" &
GAME_PID=$!

# Wait a moment for the game to fully load
sleep 2

# Try to find the game window and send F12 to show debug panel
WINDOW_ID=$(xdotool search --name "Five or More" | head -1)
if [ -n "$WINDOW_ID" ]; then
    echo "Found game window, showing debug panel..."
    xdotool windowactivate "$WINDOW_ID"
    sleep 0.5
    xdotool key F12
    echo "Debug panel should now be visible!"
    echo "Click on board cells to see line detection information."
else
    echo "Could not find game window to auto-show debug panel."
    echo "Press F12 manually to show the debug panel."
fi

# Wait for the game to finish
wait $GAME_PID
EOF

chmod +x "$TEMP_SCRIPT"

# Check if xdotool is available for auto-showing the debug panel
if command -v xdotool >/dev/null 2>&1; then
    echo "Using xdotool to automatically show debug panel..."
    "$TEMP_SCRIPT" "$SCRIPT_DIR/builddir/src/five-or-more"
else
    echo "xdotool not available - you'll need to press F12 manually to show debug panel"
    echo "To install xdotool: sudo apt install xdotool"
    echo ""
    # Run the game directly
    "$SCRIPT_DIR/builddir/src/five-or-more"
fi

# Clean up
rm -f "$TEMP_SCRIPT"