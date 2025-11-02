#!/bin/bash

# Installation script for Five or More Enhanced desktop entry
# This script installs the desktop file with the correct paths

CURRENT_DIR="$(pwd)"
DESKTOP_FILE="five-or-more-enhanced.desktop"
USER_DESKTOP_DIR="$HOME/.local/share/applications"

echo "Installing Five or More Enhanced desktop entry..."

# Create the user applications directory if it doesn't exist
mkdir -p "$USER_DESKTOP_DIR"

# Create a desktop file with the correct absolute path
cat > "$USER_DESKTOP_DIR/five-or-more-enhanced.desktop" << EOF
[Desktop Entry]
Name=Five or More Enhanced
Comment=Remove colored balls from the board by forming lines - Enhanced version with Combo Mode and Header Bar Indicators
Exec=$CURRENT_DIR/run-five-or-more-with-schema.sh
Icon=org.gnome.five-or-more
Terminal=false
Type=Application
Categories=GNOME;GTK;Game;LogicGame;
StartupNotify=true
Path=$CURRENT_DIR
Keywords=game;logic;balls;lines;combo;five;more;
EOF

# Make the desktop file executable
chmod +x "$USER_DESKTOP_DIR/five-or-more-enhanced.desktop"

echo "✓ Desktop entry installed to: $USER_DESKTOP_DIR/five-or-more-enhanced.desktop"
echo "✓ Application path: $CURRENT_DIR/run-five-or-more-with-schema.sh"
echo ""
echo "The enhanced Five or More should now appear in your application menu!"
echo "Look for 'Five or More Enhanced' in the Games category."
echo ""
echo "Features included:"
echo "• Combo Play Mode with header bar indicator"
echo "• Game Information Panel"
echo "• Enhanced accessibility support"
echo "• Configurable difficulty levels"
echo "• Composite line scoring system"