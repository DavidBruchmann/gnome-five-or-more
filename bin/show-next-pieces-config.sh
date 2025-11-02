#!/bin/bash

# Show current next pieces configuration

echo "=== Current Next Pieces Configuration ==="
echo ""

CONFIG_FILE="$HOME/.config/five-or-more/game-constants.conf"

if [ -f "$CONFIG_FILE" ]; then
    echo "Configuration file: $CONFIG_FILE"
    echo ""
    
    if grep -q "NEXT_PIECES_SIZE" "$CONFIG_FILE"; then
        SIZE=$(grep "NEXT_PIECES_SIZE" "$CONFIG_FILE" | cut -d'=' -f2)
        echo "Next Pieces Size: ${SIZE}px"
    else
        echo "Next Pieces Size: 24px (default)"
    fi
    
    if grep -q "NEXT_PIECES_SHOW_TOOLTIPS" "$CONFIG_FILE"; then
        TOOLTIPS=$(grep "NEXT_PIECES_SHOW_TOOLTIPS" "$CONFIG_FILE" | cut -d'=' -f2)
        echo "Tooltips Enabled: $TOOLTIPS"
    else
        echo "Tooltips Enabled: true (default)"
    fi
    
    echo ""
    echo "Current Theme section:"
    if grep -A 10 "\[Theme\]" "$CONFIG_FILE" | grep -E "(NEXT_PIECES_SIZE|NEXT_PIECES_SHOW_TOOLTIPS)" > /dev/null; then
        grep -A 10 "\[Theme\]" "$CONFIG_FILE" | grep -E "(NEXT_PIECES_SIZE|NEXT_PIECES_SHOW_TOOLTIPS|^$)" | head -3
    else
        echo "No next pieces configuration found - using defaults"
    fi
else
    echo "No configuration file found - using defaults:"
    echo "Next Pieces Size: 24px"
    echo "Tooltips Enabled: true"
fi

echo ""
echo "To customize next pieces:"
echo "1. Edit: $CONFIG_FILE"
echo "2. Add or modify in [Theme] section:"
echo "   NEXT_PIECES_SIZE=32"
echo "   NEXT_PIECES_SHOW_TOOLTIPS=true"
echo "3. Restart the game"