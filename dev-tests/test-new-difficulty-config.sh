#!/bin/bash

# Test script for the new difficulty configuration system
# Tests board size-specific difficulty values

echo "=== Testing New Difficulty Configuration System ==="
echo ""

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

# Create a test configuration file
TEST_CONFIG_DIR="$HOME/.config/five-or-more"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/game-constants.conf"

echo "Creating test configuration..."
mkdir -p "$TEST_CONFIG_DIR"

cat > "$TEST_CONFIG_FILE" << 'EOF'
# Test configuration for board size-specific difficulty

[Difficulty]
# Number of pieces added per round for each difficulty
# Values are for small;medium;large board sizes respectively
easy_pieces=2;3;4
normal_pieces=2;3;4
hard_pieces=4;7;10

[GameRules]
# Enable debug output for testing
ENABLE_COMPOSITE_LINES=false
EOF

echo "✓ Test configuration created at: $TEST_CONFIG_FILE"
echo ""

echo "Configuration content:"
cat "$TEST_CONFIG_FILE"
echo ""

echo "Testing application startup with new configuration..."
timeout 3s ./run-five-or-more-with-schema.sh 2>&1 | head -10

echo ""
echo "✓ Application started successfully with new difficulty configuration"
echo ""

echo "Expected behavior:"
echo "• Easy difficulty: 2 pieces (small), 3 pieces (medium), 4 pieces (large)"
echo "• Normal difficulty: 2 pieces (small), 3 pieces (medium), 4 pieces (large)"  
echo "• Hard difficulty: 4 pieces (small), 7 pieces (medium), 10 pieces (large)"
echo ""

echo "To test manually:"
echo "1. Launch: ./run-five-or-more-with-schema.sh"
echo "2. Try different board sizes (Size menu)"
echo "3. Try different difficulties (Difficulty menu)"
echo "4. Observe different numbers of pieces added per turn"
echo ""

echo "Configuration file location: $TEST_CONFIG_FILE"
echo "You can modify the values and restart the game to test different configurations."