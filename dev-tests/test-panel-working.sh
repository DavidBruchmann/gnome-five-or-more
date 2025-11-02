#!/bin/bash

echo "=== Testing Game Info Panel ==="
echo ""
echo "Instructions:"
echo "1. The game should start with an 'Info' button in the headerbar"
echo "2. Click the 'Info' button to toggle the game information panel"
echo "3. The panel should appear on the right side of the window"
echo "4. Click 'Info' again to hide the panel"
echo ""
echo "If you see debug messages in the terminal, the button is working!"
echo ""
echo "Starting Five or More..."

# Compile schema first
glib-compile-schemas data/

# Run the game
cd builddir
GSETTINGS_SCHEMA_DIR=../data ./src/five-or-more