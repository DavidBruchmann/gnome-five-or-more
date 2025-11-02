#!/bin/bash

echo "=== Testing Info Panel Button with Debug Output ==="
echo ""
echo "Starting Five or More with debug output..."
echo "Look for 'DEBUG:' messages when you click the info button (i) in the headerbar"
echo ""
echo "The button should be visible in the top-right area of the headerbar"
echo "It has an information icon (i) and should show a tooltip when you hover over it"
echo ""
echo "Press Ctrl+C to exit when done testing"
echo ""

cd builddir
GSETTINGS_SCHEMA_DIR=../data ./src/five-or-more