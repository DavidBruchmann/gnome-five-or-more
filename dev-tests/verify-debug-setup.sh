#!/bin/bash

echo "=== Debug Panel Setup Verification ==="
echo ""

# Check if all files exist
FILES_OK=0

if [ -f "launch-debug-panel.sh" ] && [ -x "launch-debug-panel.sh" ]; then
    echo "✓ launch-debug-panel.sh exists and is executable"
    ((FILES_OK++))
else
    echo "✗ launch-debug-panel.sh missing or not executable"
fi

if [ -f "five-or-more-debug.desktop" ] && [ -x "five-or-more-debug.desktop" ]; then
    echo "✓ five-or-more-debug.desktop exists and is executable"
    ((FILES_OK++))
else
    echo "✗ five-or-more-debug.desktop missing or not executable"
fi

if [ -f "DEBUG_PANEL_USAGE.md" ]; then
    echo "✓ DEBUG_PANEL_USAGE.md documentation exists"
    ((FILES_OK++))
else
    echo "✗ DEBUG_PANEL_USAGE.md documentation missing"
fi

# Check if debug panel source exists
if [ -f "src/line-detection-debug-panel.vala" ]; then
    echo "✓ Debug panel source code exists"
    ((FILES_OK++))
else
    echo "✗ Debug panel source code missing"
fi

# Check if game builds
echo ""
echo "Checking build..."
cd builddir
if ninja > /dev/null 2>&1; then
    echo "✓ Game builds successfully with debug panel"
    ((FILES_OK++))
else
    echo "✗ Game build failed"
fi

echo ""
echo "=== Setup Verification Results ==="
echo "Files/checks passed: $FILES_OK/5"

if [ $FILES_OK -eq 5 ]; then
    echo ""
    echo "🎉 Debug Panel Setup Complete!"
    echo ""
    echo "To use the debug panel:"
    echo "1. Run: ./launch-debug-panel.sh"
    echo "2. Press F12 when game starts"
    echo "3. Click on board cells to inspect line detection"
    echo ""
    echo "Or double-click: five-or-more-debug.desktop"
    echo ""
    echo "See DEBUG_PANEL_USAGE.md for detailed instructions."
else
    echo ""
    echo "❌ Setup incomplete. Please fix the issues above."
    exit 1
fi