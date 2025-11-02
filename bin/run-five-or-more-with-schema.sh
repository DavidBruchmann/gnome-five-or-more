#!/bin/bash

# Wrapper script to run Five or More with the correct schema environment
# This ensures the enable-composite-lines key is available

# Set the schema directory to use our local compiled schema
export GSETTINGS_SCHEMA_DIR=data

# Compile the schema if needed
if [ ! -f "data/gschemas.compiled" ]; then
    echo "Compiling GSettings schema..."
    glib-compile-schemas data/
fi

# Check if the key exists
if ! gsettings list-keys org.gnome.five-or-more | grep -q "enable-composite-lines"; then
    echo "Error: Schema key 'enable-composite-lines' not found!"
    echo "Make sure the schema is properly compiled."
    exit 1
fi

echo "Starting Five or More with combo mode indicator support..."
echo "Schema directory: $GSETTINGS_SCHEMA_DIR"

# Run the application
exec ./builddir/src/five-or-more "$@"