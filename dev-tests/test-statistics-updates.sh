#!/bin/bash

echo "Testing Statistics Panel Updates"
echo "================================"

# Build the game
echo "Building the game..."
cd builddir
ninja > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Build successful"
else
    echo "✗ Build failed"
    exit 1
fi

echo ""
echo "Statistics Panel Update Test:"
echo "1. Launch the game"
echo "2. Open the Statistics tab in the sidebar"
echo "3. Start a new game"
echo "4. Make some moves to create lines"
echo "5. Check that the following statistics update in real-time:"
echo "   - Current Score"
echo "   - Board Size"
echo "   - Difficulty"
echo "   - Combo Mode status"
echo "   - Line achievements (when lines are made)"
echo "   - Session statistics"
echo "   - Overall statistics"
echo ""
echo "Expected behavior:"
echo "- Current game info should update every 2 seconds"
echo "- Line achievements should update immediately when lines are made"
echo "- Session statistics should increment when lines are made"
echo "- Game completion should update overall statistics"
echo ""

# Launch the game
echo "Launching the game..."
./src/five-or-more &
GAME_PID=$!

echo "Game launched with PID: $GAME_PID"
echo ""
echo "Instructions:"
echo "1. Click on the Statistics tab in the right sidebar"
echo "2. Start a new game (Game menu > New Game)"
echo "3. Make moves to create lines and observe the statistics updates"
echo "4. Close the game when done testing"
echo ""
echo "Press Enter when you're done testing to clean up..."
read

# Clean up
if ps -p $GAME_PID > /dev/null; then
    kill $GAME_PID
    echo "Game process terminated"
fi

echo "Test completed"