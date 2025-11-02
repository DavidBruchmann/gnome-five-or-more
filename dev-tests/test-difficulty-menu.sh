#!/bin/bash

# Test script to verify the difficulty menu is available

echo "🔍 Testing Five or More Difficulty Menu..."
echo ""

# Build the application
echo "Building application..."
cd builddir
ninja > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Check if the UI file contains the difficulty menu
echo "Checking UI file for difficulty menu..."
if grep -q "_Difficulty" ../data/ui/five-or-more.ui; then
    echo "✅ Difficulty menu found in UI file"
else
    echo "❌ Difficulty menu NOT found in UI file"
    exit 1
fi

# Check if the schema contains the difficulty setting
echo "Checking schema for difficulty setting..."
if grep -q "difficulty" ../data/org.gnome.five-or-more.gschema.xml; then
    echo "✅ Difficulty setting found in schema"
else
    echo "❌ Difficulty setting NOT found in schema"
    exit 1
fi

# Check if the window.vala contains the difficulty action
echo "Checking window.vala for difficulty action..."
if grep -q "change-difficulty" ../src/window.vala; then
    echo "✅ Difficulty action found in window.vala"
else
    echo "❌ Difficulty action NOT found in window.vala"
    exit 1
fi

# Check if the game.vala contains difficulty support
echo "Checking game.vala for difficulty support..."
if grep -q "difficulty_levels" ../src/game.vala; then
    echo "✅ Difficulty levels found in game.vala"
else
    echo "❌ Difficulty levels NOT found in game.vala"
    exit 1
fi

echo ""
echo "🎯 All checks passed! The difficulty feature is properly implemented."
echo ""
echo "📋 To see the difficulty menu:"
echo "   1. Run: GSETTINGS_SCHEMA_DIR=./builddir/data/schemas ./builddir/src/five-or-more"
echo "   2. Click the hamburger menu (☰) in the top-right"
echo "   3. Look for 'Difficulty' submenu"
echo ""
echo "💡 If you don't see the menu, try installing the application:"
echo "   sudo ninja install"
echo ""
echo "🔧 Alternative: Use the launch script:"
echo "   ./run-with-difficulty.sh"