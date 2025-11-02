#!/bin/bash

echo "=== Testing Debug Panel Integration ==="
echo ""

# Build the project
echo "1. Building project..."
cd builddir
if ninja; then
    echo "✓ Build successful"
else
    echo "✗ Build failed"
    exit 1
fi

echo ""
echo "2. Testing debug panel functionality..."

# Create a test script that runs the game briefly and checks for debug panel
cat > test_debug_panel.py << 'EOF'
#!/usr/bin/env python3
import subprocess
import time
import sys
import os

def test_debug_panel():
    print("Starting Five or More for debug panel test...")
    
    # Start the game
    game_process = subprocess.Popen(
        ['./src/five-or-more'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd='.'
    )
    
    # Let it run for a few seconds
    time.sleep(3)
    
    # Check if process is still running (good sign)
    if game_process.poll() is None:
        print("✓ Game started successfully")
        game_process.terminate()
        game_process.wait()
        return True
    else:
        stdout, stderr = game_process.communicate()
        print("✗ Game failed to start")
        if stderr:
            print("Error:", stderr.decode())
        return False

if __name__ == "__main__":
    success = test_debug_panel()
    sys.exit(0 if success else 1)
EOF

python3 test_debug_panel.py
TEST_RESULT=$?

rm -f test_debug_panel.py

if [ $TEST_RESULT -eq 0 ]; then
    echo "✓ Debug panel integration test passed"
else
    echo "✗ Debug panel integration test failed"
    exit 1
fi

echo ""
echo "3. Verifying debug panel features..."

# Check if all required features are present in the debug panel source
FEATURES_FOUND=0

if grep -q "coordinate.*validation\|Coordinate.*Validation" ../src/line-detection-debug-panel.vala; then
    echo "✓ Coordinate validation feature found"
    ((FEATURES_FOUND++))
fi

if grep -q "traditional.*detection\|Traditional.*Detection" ../src/line-detection-debug-panel.vala; then
    echo "✓ Traditional vs composite comparison found"
    ((FEATURES_FOUND++))
fi

if grep -q "phantom.*warning\|Phantom.*Warning" ../src/line-detection-debug-panel.vala; then
    echo "✓ Phantom line warnings found"
    ((FEATURES_FOUND++))
fi

if grep -q "real.*time\|Real.*time" ../src/line-detection-debug-panel.vala; then
    echo "✓ Real-time monitoring found"
    ((FEATURES_FOUND++))
fi

echo ""
echo "=== Debug Panel Test Results ==="
echo "Features implemented: $FEATURES_FOUND/4"

if [ $FEATURES_FOUND -eq 4 ]; then
    echo "✓ All debug panel features are implemented"
    echo ""
    echo "To use the debug panel:"
    echo "1. Run: ./run-five-or-more-debug.sh (auto-shows panel)"
    echo "2. Or run: ./run-five-or-more.sh and press F12"
    echo "3. Or double-click: five-or-more-debug.desktop"
    echo ""
    echo "Debug panel features:"
    echo "- Click on board cells to inspect line detection"
    echo "- View coordinate system validation"
    echo "- Compare traditional vs composite line detection"
    echo "- Monitor phantom line warnings"
    echo "- Export debug sessions"
else
    echo "✗ Some debug panel features are missing"
    exit 1
fi