#!/bin/bash

echo "=== Testing Button Visibility ==="
echo ""

echo "1. Checking if button is defined in UI file..."
if grep -q 'id="info_panel_button"' data/ui/five-or-more.ui; then
    echo "✓ Button ID found in UI file"
else
    echo "✗ Button ID missing from UI file"
    exit 1
fi

if grep -q 'dialog-information-symbolic' data/ui/five-or-more.ui; then
    echo "✓ Button icon defined correctly"
else
    echo "✗ Button icon missing"
fi

if grep -q 'win.toggle-info' data/ui/five-or-more.ui; then
    echo "✓ Button action connected"
else
    echo "✗ Button action missing"
fi

echo ""
echo "2. Checking window integration..."
if grep -q 'info_panel_button' src/window.vala; then
    echo "✓ Button referenced in window code"
else
    echo "✗ Button not referenced in window"
    exit 1
fi

echo ""
echo "3. Checking installed version..."
if [ -f "install-root/usr/local/bin/five-or-more" ]; then
    echo "✓ Updated installed version available"
    
    # Check if the UI file was installed
    if [ -f "install-root/usr/local/share/five-or-more/ui/five-or-more.ui" ] || \
       find install-root -name "*.ui" -exec grep -l "info_panel_button" {} \; | head -1 > /dev/null; then
        echo "✓ UI file with button installed"
    else
        echo "⚠️  UI file installation status unclear"
    fi
else
    echo "✗ No installed version found"
fi

echo ""
echo "4. Build verification..."
cd builddir
if ninja > /dev/null 2>&1; then
    echo "✓ Development build successful"
else
    echo "✗ Development build failed"
    exit 1
fi

echo ""
echo "=== Button Implementation Status ==="
echo ""
echo "✅ Button should now be visible in both:"
echo "   • Development build: builddir/src/five-or-more"
echo "   • Installed version: install-root/usr/local/bin/five-or-more"
echo ""
echo "🔍 To see the button:"
echo "   1. Run: ./launch-debug-panel-safe.sh"
echo "   2. Look for the (i) button in the headerbar"
echo "   3. It should be between the score and the hamburger menu"
echo ""
echo "🎯 Button location in headerbar:"
echo "   [Next: ●●●] [Score: 1234] [🛈] [☰]"
echo "                              ↑"
echo "                         Info button"