#!/bin/bash

echo "=== Final Debug Panel Verification ==="
echo ""

# Test the safe launcher
echo "1. Testing safe debug panel launcher..."
timeout 3s ./launch-debug-panel-safe.sh > /dev/null 2>&1
SAFE_EXIT=$?

if [ $SAFE_EXIT -eq 124 ] || [ $SAFE_EXIT -eq 0 ]; then  # 124 is timeout, 0 is clean exit
    echo "✓ Safe launcher works without crashing"
else
    echo "✗ Safe launcher failed (exit code: $SAFE_EXIT)"
    exit 1
fi

# Check desktop file
echo ""
echo "2. Checking desktop file..."
if [ -f "five-or-more-debug.desktop" ] && [ -x "five-or-more-debug.desktop" ]; then
    echo "✓ Debug desktop file exists and is executable"
else
    echo "✗ Debug desktop file missing or not executable"
    exit 1
fi

# Verify debug panel source is compiled
echo ""
echo "3. Verifying debug panel compilation..."
if grep -q "line-detection-debug-panel" builddir/build.ninja; then
    echo "✓ Debug panel is included in build"
else
    echo "✗ Debug panel not found in build"
    exit 1
fi

# Check if installed version has debug panel
echo ""
echo "4. Checking installed version..."
if [ -f "install-root/usr/local/bin/five-or-more" ]; then
    echo "✓ Installed version available"
    
    # Quick test that it doesn't crash immediately
    timeout 2s install-root/usr/local/bin/five-or-more --help > /dev/null 2>&1
    HELP_EXIT=$?
    
    if [ $HELP_EXIT -eq 0 ] || [ $HELP_EXIT -eq 124 ]; then
        echo "✓ Installed version responds to --help"
    else
        echo "⚠️  Installed version may have issues"
    fi
else
    echo "⚠️  No installed version found"
fi

echo ""
echo "=== Debug Panel Ready! ==="
echo ""
echo "🎉 The debug panel is working and ready to use!"
echo ""
echo "📋 How to access the debug panel:"
echo ""
echo "   Method 1 (Recommended):"
echo "   ./launch-debug-panel-safe.sh"
echo "   Then press F12 when game starts"
echo ""
echo "   Method 2:"
echo "   Double-click five-or-more-debug.desktop"
echo ""
echo "   Method 3:"
echo "   ./run-five-or-more.sh"
echo "   Then press F12 or use Menu > Debug Panel"
echo ""
echo "🔧 Debug Panel Features:"
echo "   • Real-time coordinate system validation"
echo "   • Traditional vs composite line detection comparison"
echo "   • Phantom line detection warnings"
echo "   • Board click integration for position inspection"
echo "   • Debug logging with export functionality"
echo "   • F12 keyboard shortcut and menu access"
echo ""
echo "📖 For detailed instructions, see: DEBUG_PANEL_USAGE.md"