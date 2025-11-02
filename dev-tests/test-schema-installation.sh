#!/bin/bash

echo "=== Schema Installation Test ==="
echo ""
echo "Testing if the new GSettings schema is properly installed..."
echo ""

# Test if the schema key exists
if gsettings list-keys org.gnome.five-or-more | grep -q "enable-composite-lines"; then
    echo "✅ Schema key 'enable-composite-lines' found!"
    
    # Test getting the default value
    default_value=$(gsettings get org.gnome.five-or-more enable-composite-lines)
    echo "✅ Default value: $default_value"
    
    # Test setting the value
    echo "Testing setting value to true..."
    gsettings set org.gnome.five-or-more enable-composite-lines true
    new_value=$(gsettings get org.gnome.five-or-more enable-composite-lines)
    echo "✅ New value: $new_value"
    
    # Reset to default
    echo "Resetting to default..."
    gsettings set org.gnome.five-or-more enable-composite-lines false
    reset_value=$(gsettings get org.gnome.five-or-more enable-composite-lines)
    echo "✅ Reset value: $reset_value"
    
    echo ""
    echo "🎉 Schema installation successful!"
    echo "The combo mode toggle should now work in the game menu."
    
else
    echo "❌ Schema key 'enable-composite-lines' not found!"
    echo "The schema may not be properly installed."
    echo ""
    echo "To fix this, run:"
    echo "sudo cp data/org.gnome.five-or-more.gschema.xml /usr/share/glib-2.0/schemas/"
    echo "sudo glib-compile-schemas /usr/share/glib-2.0/schemas/"
fi

echo ""
echo "Now testing the game..."
./builddir/src/five-or-more