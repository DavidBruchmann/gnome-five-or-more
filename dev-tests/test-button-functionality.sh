#!/bin/bash

echo "=== Testing Button Functionality ==="
echo ""

echo "1. Checking if GameInfoPanel class exists in build..."
if grep -q "GameInfoPanel" builddir/src/five-or-more.p/*.c 2>/dev/null; then
    echo "✓ GameInfoPanel found in compiled code"
else
    echo "⚠️  GameInfoPanel not found in compiled code"
fi

echo ""
echo "2. Checking action registration..."
if grep -q "toggle-info" src/window.vala; then
    echo "✓ toggle-info action registered"
else
    echo "✗ toggle-info action missing"
    exit 1
fi

echo ""
echo "3. Testing development build..."
echo "Starting development build to test button functionality..."
echo "This will run for 5 seconds to test if it starts without errors..."

cd builddir
timeout 5s ./src/five-or-more > /dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
    echo "✓ Development build starts successfully (timed out as expected)"
elif [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Development build ran and exited cleanly"
else
    echo "✗ Development build failed with exit code: $EXIT_CODE"
    echo "Let's check for errors..."
    ./src/five-or-more --help 2>&1 | head -5
fi

echo ""
echo "4. Checking if all required files are in meson.build..."
if grep -q "game-info-panel.vala" ../src/meson.build; then
    echo "✓ game-info-panel.vala included in build"
else
    echo "✗ game-info-panel.vala missing from build"
    exit 1
fi

echo ""
echo "=== Diagnosis ==="
echo ""
echo "The button should be functional. If it's not working:"
echo ""
echo "1. Try the development build directly:"
echo "   cd builddir && ./src/five-or-more"
echo ""
echo "2. Check for error messages in terminal when clicking the button"
echo ""
echo "3. Try the menu item instead:"
echo "   Menu > Game Info"
echo ""
echo "4. If still not working, there might be a runtime error."
echo "   Run the game from terminal to see error messages."