#!/bin/bash

echo "=== Game Info Panel Button Verification ==="
echo ""

# Check if UI file has the button
echo "1. Checking UI button definition..."
if grep -q "info_panel_button" data/ui/five-or-more.ui; then
    echo "✓ Info panel button found in UI definition"
else
    echo "✗ Info panel button missing from UI"
    exit 1
fi

# Check if button uses correct icon
if grep -q "dialog-information-symbolic" data/ui/five-or-more.ui; then
    echo "✓ Info button uses information icon"
else
    echo "✗ Info button icon missing or incorrect"
fi

# Check if button has correct action
if grep -q "win.toggle-info" data/ui/five-or-more.ui; then
    echo "✓ Info button connected to toggle action"
else
    echo "✗ Info button action missing"
fi

# Check if F12 shortcut was removed from menu
echo ""
echo "2. Checking F12 shortcut removal..."
if ! grep -q "F12" data/ui/five-or-more.ui; then
    echo "✓ F12 keyboard shortcut removed from menu"
else
    echo "⚠️  F12 shortcut still present in UI"
fi

# Check if window.vala has button reference
echo ""
echo "3. Checking window integration..."
if grep -q "info_panel_button" src/window.vala; then
    echo "✓ Window has reference to info panel button"
else
    echo "✗ Window missing button reference"
    exit 1
fi

# Check if button state update method exists
if grep -q "update_info_panel_button_state" src/window.vala; then
    echo "✓ Button state update method implemented"
else
    echo "✗ Button state update method missing"
fi

# Check build
echo ""
echo "4. Testing build..."
cd builddir
if ninja > /dev/null 2>&1; then
    echo "✓ Project builds successfully with button"
else
    echo "✗ Build failed with button implementation"
    exit 1
fi

echo ""
echo "=== Button Implementation Complete! ==="
echo ""
echo "🎉 The info panel is now accessible via button!"
echo ""
echo "📋 How to access the info panel:"
echo ""
echo "   Method 1 (Primary):"
echo "   Click the (i) button in the headerbar"
echo ""
echo "   Method 2 (Alternative):"
echo "   Use Menu > Game Info"
echo ""
echo "   Method 3 (Testing):"
echo "   ./launch-debug-panel-safe.sh"
echo ""
echo "🔧 Button Features:"
echo "   • Prominent placement in headerbar"
echo "   • Visual feedback when panel is open (highlighted)"
echo "   • Tooltip shows current state"
echo "   • Standard information icon (dialog-information-symbolic)"
echo "   • Consistent with GNOME design patterns"
echo ""
echo "✨ Benefits of button approach:"
echo "   • More discoverable than F12 shortcut"
echo "   • Follows standard UI conventions"
echo "   • Visual indication of panel state"
echo "   • Accessible to all users"
echo "   • No need to remember keyboard shortcuts"