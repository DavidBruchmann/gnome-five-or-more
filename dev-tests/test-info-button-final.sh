#!/bin/bash

echo "=== Final Info Panel Button Test ==="
echo ""
echo "Changes made:"
echo "✓ Button now shows 'Info' text instead of icon"
echo "✓ Button uses suggested-action style (should be blue/prominent)"
echo "✓ Added debug output to track button clicks"
echo ""
echo "What to look for:"
echo "1. Blue 'Info' button in the headerbar (top-right area)"
echo "2. Debug messages in terminal when clicking the button"
echo "3. Game info panel should appear on the right side"
echo ""
echo "Starting Five or More..."
echo "Click the 'Info' button to test the panel!"
echo ""

cd builddir
GSETTINGS_SCHEMA_DIR=../data ./src/five-or-more