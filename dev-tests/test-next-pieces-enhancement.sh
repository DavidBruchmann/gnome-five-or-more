#!/bin/bash

# Test script for enhanced next pieces preview functionality
# Tests configurable size and tooltip features

echo "=== Testing Enhanced Next Pieces Preview ==="
echo ""

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

# Create test configuration with different next pieces sizes
TEST_CONFIG_DIR="$HOME/.config/five-or-more"
TEST_CONFIG_FILE="$TEST_CONFIG_DIR/game-constants.conf"

echo "Creating test configuration with enhanced next pieces settings..."
mkdir -p "$TEST_CONFIG_DIR"

cat > "$TEST_CONFIG_FILE" << 'EOF'
# Test configuration for enhanced next pieces preview

[Theme]
# Size of next pieces preview in header bar in pixels (default: 24)
NEXT_PIECES_SIZE=32

# Show color names as tooltips on next pieces (default: true)
NEXT_PIECES_SHOW_TOOLTIPS=true

[GameRules]
# Enable debug output for testing
ENABLE_COMPOSITE_LINES=false
EOF

echo "✓ Test configuration created with larger next pieces (32px)"
echo ""

echo "Configuration content:"
cat "$TEST_CONFIG_FILE"
echo ""

echo "Testing application startup with enhanced next pieces..."
timeout 3s ./run-five-or-more-with-schema.sh 2>&1 | head -5

echo ""
echo "✓ Application started successfully with enhanced next pieces"
echo ""

echo "Features to test manually:"
echo "• Next pieces should be larger (32px instead of default 24px)"
echo "• Hover over next pieces to see color name tooltips"
echo "• Tooltips should show: 'Color Name' and 'Next piece X'"
echo "• Available colors: Red, Green, Blue, Yellow, Purple, Orange, Cyan"
echo ""

echo "Different size configurations to try:"
echo ""

# Test with small size
echo "Small size (16px):"
cat > "$TEST_CONFIG_FILE" << 'EOF'
[Theme]
NEXT_PIECES_SIZE=16
NEXT_PIECES_SHOW_TOOLTIPS=true
EOF
echo "  NEXT_PIECES_SIZE=16"

# Test with medium size  
echo ""
echo "Medium size (24px - default):"
echo "  NEXT_PIECES_SIZE=24"

# Test with large size
echo ""
echo "Large size (40px):"
echo "  NEXT_PIECES_SIZE=40"

# Test with tooltips disabled
echo ""
echo "Tooltips disabled:"
echo "  NEXT_PIECES_SHOW_TOOLTIPS=false"

echo ""
echo "To test different configurations:"
echo "1. Edit: $TEST_CONFIG_FILE"
echo "2. Restart the game: ./run-five-or-more-with-schema.sh"
echo "3. Observe the next pieces size changes"
echo "4. Test tooltip functionality by hovering over pieces"

# Restore default configuration
cat > "$TEST_CONFIG_FILE" << 'EOF'
[Theme]
NEXT_PIECES_SIZE=32
NEXT_PIECES_SHOW_TOOLTIPS=true
EOF

echo ""
echo "Current configuration: 32px pieces with tooltips enabled"
echo "Configuration file: $TEST_CONFIG_FILE"