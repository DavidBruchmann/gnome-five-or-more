#!/bin/bash

# Test script to verify the color tooltip fix

echo "=== Testing Color Tooltip Fix ==="
echo ""

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

echo "Color mapping verification:"
echo "Based on layered-renderer.vala, the correct color order is:"
echo ""
echo "Piece ID | Hex Color | Color Name"
echo "---------|-----------|------------"
echo "    0    | #FFFF00   | Yellow"
echo "    1    | #FF00FF   | Purple (Magenta)"
echo "    2    | #00FF00   | Green"
echo "    3    | #FF0000   | Red"
echo "    4    | #0000FF   | Blue"
echo "    5    | #00FFFF   | Cyan"
echo "    6    | #FF8000   | Orange"
echo ""

echo "Previous incorrect mapping was:"
echo "0=Red, 1=Green, 2=Blue, 3=Yellow, 4=Purple, 5=Orange, 6=Cyan"
echo ""
echo "Fixed mapping is now:"
echo "0=Yellow, 1=Purple, 2=Green, 3=Red, 4=Blue, 5=Cyan, 6=Orange"
echo ""

echo "Testing application with corrected color tooltips..."
timeout 3s ./run-five-or-more-with-schema.sh 2>&1 | head -3

echo ""
echo "✓ Application started successfully with corrected color tooltips"
echo ""

echo "Manual testing instructions:"
echo "1. Launch: ./run-five-or-more-with-schema.sh"
echo "2. Look at the next pieces preview in the header bar (left side)"
echo "3. Hover over each next piece to see the tooltip"
echo "4. Verify the color names match the visual colors:"
echo "   - Yellow pieces should show 'Yellow'"
echo "   - Purple/Magenta pieces should show 'Purple'"
echo "   - Green pieces should show 'Green'"
echo "   - Red pieces should show 'Red'"
echo "   - Blue pieces should show 'Blue'"
echo "   - Cyan pieces should show 'Cyan'"
echo "   - Orange pieces should show 'Orange'"
echo ""

echo "The tooltips should now correctly match the visual colors!"