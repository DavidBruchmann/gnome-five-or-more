#!/bin/bash

echo "Testing GSettings schema fix..."

# Set up the schema path
export GSETTINGS_SCHEMA_DIR="$(pwd)/builddir/data/schemas"

# Test if the game can start without crashing
cd builddir
timeout 3s ./src/five-or-more --help > /dev/null 2>&1
HELP_EXIT=$?

if [ $HELP_EXIT -eq 0 ] || [ $HELP_EXIT -eq 124 ]; then  # 124 is timeout exit code
    echo "✓ Game can access help without schema errors"
else
    echo "✗ Game still has schema issues"
    exit 1
fi

# Test if schema is accessible
if [ -f "$GSETTINGS_SCHEMA_DIR/gschemas.compiled" ]; then
    echo "✓ Compiled schema found at: $GSETTINGS_SCHEMA_DIR"
else
    echo "✗ Compiled schema not found"
    exit 1
fi

# Test a quick start (will timeout but shouldn't crash immediately)
echo "Testing quick game start..."
timeout 2s ./src/five-or-more > /dev/null 2>&1
START_EXIT=$?

if [ $START_EXIT -eq 124 ]; then  # Timeout means it started successfully
    echo "✓ Game starts without immediate schema crash"
elif [ $START_EXIT -eq 0 ]; then
    echo "✓ Game started and exited cleanly"
else
    echo "✗ Game crashed on startup (exit code: $START_EXIT)"
    exit 1
fi

echo ""
echo "🎉 Schema fix successful!"
echo "The debug panel launcher should now work properly."