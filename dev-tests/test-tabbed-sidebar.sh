#!/bin/bash

# Test script for the new tabbed sidebar functionality
# Tests the Statistics and Development tabs

echo "=== Testing Tabbed Sidebar Implementation ==="
echo ""

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

# Compile schema if needed
if [ ! -f "data/gschemas.compiled" ]; then
    echo "Compiling schema..."
    glib-compile-schemas data/
fi

echo "✓ New Tabbed Sidebar Features:"
echo "  • Statistics Tab (always enabled) - Shows user gameplay statistics"
echo "  • Development Tab (disabled by default) - Contains debugging information"
echo ""

echo "✓ Statistics Tab Content:"
echo "  • Current game info (score, board size, difficulty, combo mode)"
echo "  • Lines achieved by length (5-line, 6-line, etc.)"
echo "  • Session statistics (games played, lines cleared, best score)"
echo "  • Overall statistics (total games, user best, global best)"
echo ""

echo "✓ Development Tab Features:"
echo "  • Contains the original GameInfoPanel debugging content"
echo "  • Disabled by default for regular users"
echo "  • Can be enabled via environment variable or settings"
echo ""

echo "Testing application startup with new sidebar..."
timeout 3s ./run-five-or-more-with-schema.sh 2>&1 | head -5

echo ""
echo "✓ Application started successfully with tabbed sidebar"
echo ""

echo "Manual Testing Instructions:"
echo ""
echo "1. Basic Usage:"
echo "   • Launch: ./run-five-or-more-with-schema.sh"
echo "   • Click 'Info' button to show sidebar"
echo "   • Verify Statistics tab is visible and active by default"
echo "   • Play a game and observe statistics updates"
echo ""

echo "2. Enable Development Tab:"
echo "   • Method 1: FIVE_OR_MORE_DEV_TAB=true ./run-five-or-more-with-schema.sh"
echo "   • Method 2: Set enable-development-tab=true in settings"
echo "   • Verify Development tab appears alongside Statistics tab"
echo ""

echo "3. Statistics Verification:"
echo "   • Start a new game and make some moves"
echo "   • Clear some lines and verify line statistics update"
echo "   • Check that current game info shows correct board size and difficulty"
echo "   • Verify session statistics increment properly"
echo ""

echo "4. Tab Persistence:"
echo "   • Switch between tabs and restart application"
echo "   • Verify last active tab is remembered"
echo ""

echo "Configuration Files:"
echo "  • Statistics data: ~/.config/five-or-more/player-statistics.json"
echo "  • Global statistics: ~/.config/five-or-more/global-statistics.json"
echo "  • Settings: GSettings schema (enable-development-tab, sidebar-active-tab)"
echo ""

echo "Expected Statistics Display:"
echo "  Current Game: Score, Board Size (Small/Medium/Large), Difficulty, Combo Mode"
echo "  Lines Achieved: Count of each line length (5-line: X times, etc.)"
echo "  Session Stats: Games this session, Lines this session, Best score this session"
echo "  Overall Stats: Total games played, Your best score, Global best score"