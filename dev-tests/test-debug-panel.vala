/*
 * Test for Line Detection Debug Panel
 */

using Gtk;

int main (string[] args) {
    Gtk.init (ref args);
    
    var window = new ApplicationWindow (new Application ("org.gnome.five-or-more.test", ApplicationFlags.FLAGS_NONE));
    window.set_title ("Debug Panel Test");
    window.set_default_size (800, 600);
    
    // Create a simple game instance for testing
    var game = new Game (2, 1); // Medium board, normal difficulty
    
    // Create debug panel
    var debug_panel = new LineDetectionDebugPanel ();
    debug_panel.set_game (game);
    
    // Create a simple layout
    var main_box = new Box (Orientation.HORIZONTAL, 0);
    
    // Add a placeholder for the game area
    var game_placeholder = new Label ("Game Area\n(Click F12 to toggle debug panel)");
    game_placeholder.set_size_request (400, 400);
    game_placeholder.get_style_context ().add_class ("frame");
    
    main_box.pack_start (game_placeholder, true, true, 0);
    main_box.pack_start (debug_panel, false, false, 0);
    
    window.add (main_box);
    
    // Test debug panel functionality
    debug_panel.set_selected_position (2, 3);
    debug_panel.update_all_displays ();
    
    window.show_all ();
    
    print ("Debug panel test started. Press Ctrl+C to exit.\n");
    print ("Debug panel should be visible on the right side.\n");
    print ("Game information should be displayed in the debug panel.\n");
    
    Gtk.main ();
    
    return 0;
}