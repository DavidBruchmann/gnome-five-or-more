#!/bin/bash

echo "🔍 Testing Boundary Bug - Including User-Reported Case"
echo "=================================================="

# Compile the test
echo "Compiling boundary bug test..."
valac --pkg gtk+-3.0 --pkg gee-0.8 test-boundary-bug.vala src/game.vala src/board.vala src/line-detector.vala -o test-boundary-bug

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
    echo ""
    
    # Run the test
    echo "Running boundary bug test..."
    ./test-boundary-bug
    
    # Clean up
    rm -f test-boundary-bug
else
    echo "❌ Compilation failed"
    echo "This might be due to missing dependencies or the boundary bug affecting compilation"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. If test shows coordinate mismatches, the boundary bug is confirmed"
echo "2. Check if your reported 9x9 board issue matches the coordinate problems"
echo "3. Fix the GameDifficulty array or board creation logic"
echo "4. Re-test the specific row 4, columns 5-8 scenario"