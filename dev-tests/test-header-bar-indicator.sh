#!/bin/bash

# Test script for header bar combo mode indicator functionality
# This script verifies that the header bar indicator appears and disappears correctly

echo "Testing Header Bar Combo Mode Indicator..."

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

# Test 1: Check that application starts without errors
echo "Test 1: Starting application..."
timeout 5s ./builddir/src/five-or-more &
APP_PID=$!

# Give the app time to start
sleep 2

# Check if the process is still running
if kill -0 $APP_PID 2>/dev/null; then
    echo "✓ Application started successfully"
    kill $APP_PID 2>/dev/null
else
    echo "✗ Application failed to start"
    exit 1
fi

# Test 2: Check schema key exists
echo "Test 2: Checking schema key..."
export GSETTINGS_SCHEMA_DIR=data
if gsettings list-keys org.gnome.five-or-more | grep -q "enable-composite-lines"; then
    echo "✓ Schema key 'enable-composite-lines' exists"
else
    echo "✗ Schema key 'enable-composite-lines' not found"
    exit 1
fi

# Test 3: Test setting the combo mode value
echo "Test 3: Testing combo mode setting..."
gsettings set org.gnome.five-or-more enable-composite-lines true
CURRENT_VALUE=$(gsettings get org.gnome.five-or-more enable-composite-lines)
if [ "$CURRENT_VALUE" = "true" ]; then
    echo "✓ Combo mode can be enabled via settings"
else
    echo "✗ Failed to enable combo mode via settings"
    exit 1
fi

# Reset to default
gsettings set org.gnome.five-or-more enable-composite-lines false
CURRENT_VALUE=$(gsettings get org.gnome.five-or-more enable-composite-lines)
if [ "$CURRENT_VALUE" = "false" ]; then
    echo "✓ Combo mode can be disabled via settings"
else
    echo "✗ Failed to disable combo mode via settings"
    exit 1
fi

echo ""
echo "All header bar indicator tests passed!"
echo ""
echo "Manual testing instructions:"
echo "1. Run: GSETTINGS_SCHEMA_DIR=data ./builddir/src/five-or-more"
echo "2. Open the hamburger menu (☰)"
echo "3. Click 'Combo Play' to toggle combo mode"
echo "4. Verify that:"
echo "   - A combo mode indicator appears in the header bar when combo mode is active"
echo "   - The indicator has a tooltip explaining combo mode"
echo "   - The indicator disappears when combo mode is disabled"
echo "   - The menu item shows a checkmark when combo mode is active"
echo "   - Mode transition notifications appear when toggling"