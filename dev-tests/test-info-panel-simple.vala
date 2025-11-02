/*
 * Simple test to verify GameInfoPanel instantiation
 */

using Gtk;

int main (string[] args) {
    Gtk.init (ref args);
    
    try {
        print ("Creating GameInfoPanel...\n");
        var panel = new GameInfoPanel ();
        print ("✓ GameInfoPanel created successfully\n");
        
        print ("Testing panel visibility...\n");
        panel.show_all ();
        print ("✓ Panel can be shown\n");
        
        print ("All tests passed!\n");
        return 0;
    } catch (Error e) {
        print ("✗ Error: %s\n", e.message);
        return 1;
    }
}