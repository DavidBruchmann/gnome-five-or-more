#!/bin/bash

# Comprehensive launcher for Five or More Enhanced
# Provides options for different launch modes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set up environment
export GSETTINGS_SCHEMA_DIR=data

# Compile schema if needed
if [ ! -f "data/gschemas.compiled" ]; then
    echo "Compiling GSettings schema..."
    glib-compile-schemas data/
fi

# Check arguments for launch mode
case "${1:-normal}" in
    "debug")
        echo "Launching Five or More in debug mode..."
        exec ./builddir/src/five-or-more
        ;;
    "info")
        echo "Launching Five or More with info panel visible..."
        # Set info panel to be visible by default
        gsettings set org.gnome.five-or-more enable-composite-lines true
        exec ./builddir/src/five-or-more
        ;;
    "combo")
        echo "Launching Five or More with combo mode enabled..."
        gsettings set org.gnome.five-or-more enable-composite-lines true
        exec ./builddir/src/five-or-more
        ;;
    "normal"|*)
        echo "Launching Five or More Enhanced..."
        exec ./builddir/src/five-or-more
        ;;
esac