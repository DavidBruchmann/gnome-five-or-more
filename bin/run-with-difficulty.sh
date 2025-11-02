#!/bin/bash

# Script to run Five or More with the new difficulty feature
# This ensures the local schema is used

echo "🎮 Launching Five or More with Difficulty Feature..."
echo ""

# Set up environment to use local schema
export GSETTINGS_SCHEMA_DIR="$(pwd)/builddir/data/schemas"

# Check if the application exists
if [ ! -f "builddir/src/five-or-more" ]; then
    echo "❌ Application not found. Please build first:"
    echo "   cd builddir && ninja"
    exit 1
fi

# Check if schema exists
if [ ! -f "$GSETTINGS_SCHEMA_DIR/gschemas.compiled" ]; then
    echo "❌ Schema not compiled. Please build first:"
    echo "   cd builddir && ninja"
    exit 1
fi

echo "📋 Environment:"
echo "   Schema directory: $GSETTINGS_SCHEMA_DIR"
echo "   Application: $(pwd)/builddir/src/five-or-more"
echo ""

echo "🚀 Starting Five or More..."
echo "   Look for the 'Difficulty' menu in the hamburger menu (☰)"
echo ""

# Launch the application
cd builddir
./src/five-or-more

echo ""
echo "✅ Five or More closed."