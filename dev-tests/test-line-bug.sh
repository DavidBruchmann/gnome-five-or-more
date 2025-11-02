#!/bin/bash

echo "🐛 Testing Line Detection Bug"
echo ""

echo "Building debug version..."
cd builddir
ninja > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"
echo ""

echo "The bug you reported suggests that 4-piece lines are being removed."
echo "This should NOT happen according to the game rules (minimum 5 pieces)."
echo ""

echo "📋 Analysis of the code:"
echo "  • N_MATCH constant is correctly set to 5"
echo "  • Traditional line detection checks: list.size >= Game.N_MATCH"
echo "  • Composite line detection checks: total_length >= Game.N_MATCH"
echo ""

echo "🔍 Possible causes:"
echo "  1. Bug in get_direction() method counting cells incorrectly"
echo "  2. Bug in composite line detection calculating wrong total_length"
echo "  3. Bug in get_all_lines_composite() logic flow"
echo "  4. Race condition or state corruption during animation"
echo ""

echo "🎯 To reproduce:"
echo "  1. Create exactly 4 pieces in a line"
echo "  2. Make a move that places a piece adjacent to this line"
echo "  3. Observe if the 4-piece line gets removed"
echo ""

echo "💡 Recommendation:"
echo "  Add debug logging to track line detection decisions"
echo "  or create a unit test that reproduces the exact scenario"