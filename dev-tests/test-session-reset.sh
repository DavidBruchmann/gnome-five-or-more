#!/bin/bash

echo "Testing Session Reset Functionality"
echo "==================================="

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
echo "Session Reset Test Instructions:"
echo "1. Launch the game"
echo "2. Open the Statistics tab in the sidebar"
echo "3. Start a new game and make some moves to create lines"
echo "4. Observe the 'Lines This Game' section shows your achievements"
echo "5. Start a new game (Game menu > New Game)"
echo "6. Verify that 'Lines This Game' resets to 'No lines achieved yet'"
echo "7. Verify that 'Session Statistics' shows cumulative data"
echo "8. Verify that 'All-Time Line Achievements' shows persistent data"
echo ""
echo "Expected behavior:"
echo "- 'Lines This Game' should reset to zero when starting a new game"
echo "- 'Session Statistics' should accumulate across games in the session"
echo "- 'All-Time Line Achievements' should persist across all sessions"
echo "- 'Overall Statistics' should show persistent totals"
echo ""

# Launch the game
echo "Launching the game..."
./src/five-or-more &
GAME_PID=$!

echo "Game launched with PID: $GAME_PID"
echo ""
echo "Test the following scenarios:"
echo "1. Make lines in a game and observe 'Lines This Game' updates"
echo "2. Start a new game and verify 'Lines This Game' resets"
echo "3. Make more lines and start another new game"
echo "4. Check that session and all-time statistics accumulate properly"
echo ""
echo "Press Enter when you're done testing to clean up..."
read

# Clean up
if ps -p $GAME_PID > /dev/null; then
    kill $GAME_PID
    echo "Game process terminated"
fi

echo "Test completed"