#!/bin/bash

# Demo script for header bar combo mode indicator
# This script demonstrates the functionality implemented in Task 2

echo "=== Header Bar Combo Mode Indicator Demo ==="
echo ""

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

echo "Current combo mode setting:"
CURRENT_STATE=$(gsettings get org.gnome.five-or-more enable-composite-lines)
echo "  enable-composite-lines = $CURRENT_STATE"
echo ""

echo "Starting Five or More with header bar indicator..."
echo "Look for the combo mode indicator in the header bar!"
echo ""
echo "What to test:"
echo "1. ✓ Header bar shows combo mode indicator when active"
echo "2. ✓ Indicator has tooltip: 'Combo Play Mode Active - gap-separated patterns count as lines'"
echo "3. ✓ Indicator supports keyboard navigation (Tab to focus, Enter/Space to toggle)"
echo "4. ✓ Indicator can be clicked to toggle combo mode"
echo "5. ✓ Screen reader announces mode changes"
echo "6. ✓ Menu shows checkmark when combo mode is active"
echo ""
echo "To test:"
echo "- Open hamburger menu (☰) and click 'Combo Play' to toggle"
echo "- Use Tab key to navigate to the indicator and press Enter/Space"
echo "- Hover over the indicator to see the tooltip"
echo ""
echo "Press Ctrl+C to exit the application when done testing."
echo ""

# Start the application with proper schema support
./run-five-or-more-with-schema.sh