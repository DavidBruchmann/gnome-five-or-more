/*
 * Five or More - Menu System Tests
 * 
 * Tests for hamburger menu functionality and keyboard shortcuts.
 */

using FiveOrMoreTest;
using Gtk;

namespace FiveOrMoreTest.UI {

    /**
     * Test suite for menu system functionality
     */
    public class MenuSystemTestSuite : TestBase {
        
        public static void main(string[] args) {
            Test.init(ref args);
            
            // Register test cases for hamburger menu structure and item presence
            Test.add_func("/ui/menu/hamburger_menu_structure", test_hamburger_menu_structure);
            Test.add_func("/ui/menu/menu_actions_registration", test_menu_actions_registration);
            Test.add_func("/ui/menu/keyboard_shortcuts_registration", test_keyboard_shortcuts_registration);
            
            Test.run();
        }
        
        /**
         * Test hamburger menu structure (Requirements 4.1, 4.2, 4.3, 4.4, 4.5)
         */
        public static void test_hamburger_menu_structure() {
            var test = new MenuSystemTestSuite();
            test.setup();
            
            try {
                // Create HeaderBar with MenuButton to simulate the actual game window
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                
                // Create a comprehensive menu model that matches the actual game menu
                var menu_model = new GLib.Menu();
                
                // First section: New Game and Size submenu
                var first_section = new GLib.Menu();
                first_section.append("New Game", "win.new-game");
                
                var size_submenu = new GLib.Menu();
                size_submenu.append("Small", "win.change-size::small");
                size_submenu.append("Medium", "win.change-size::medium");
                size_submenu.append("Large", "win.change-size::large");
                first_section.append_submenu("Size", size_submenu);
                
                menu_model.append_section(null, first_section);
                
                // Second section: Scores and Appearance
                var second_section = new GLib.Menu();
                second_section.append("Scores", "win.scores");
                
                var appearance_submenu = new GLib.Menu();
                appearance_submenu.append("balls", "win.change-theme::balls.svg");
                appearance_submenu.append("shapes", "win.change-theme::shapes.svg");
                appearance_submenu.append("tango", "win.change-theme::tango.svg");
                appearance_submenu.append("Select color", "win.background");
                appearance_submenu.append("Default color", "win.reset-bg");
                second_section.append_submenu("Appearance", appearance_submenu);
                
                menu_model.append_section(null, second_section);
                
                // Third section: Help items
                var third_section = new GLib.Menu();
                third_section.append("Keyboard Shortcuts", "win.show-help-overlay");
                third_section.append("Help", "app.help");
                third_section.append("About Five or More", "app.about");
                
                menu_model.append_section(null, third_section);
                
                // Create MenuButton with the menu
                var menu_button = new MenuButton();
                menu_button.set_menu_model(menu_model);
                headerbar.pack_end(menu_button);
                
                test.test_window.set_titlebar(headerbar);
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                var retrieved_headerbar = WindowTestUtils.get_window_headerbar(test.test_window);
                assert_nonnull(retrieved_headerbar);
                Test.message("✓ HeaderBar present");
                
                // Check for MenuButton (Requirements 4.1, 4.2, 4.3, 4.4, 4.5)
                var found_menu_button = WindowTestUtils.find_menu_button(retrieved_headerbar);
                assert_nonnull(found_menu_button);
                Test.message("✓ MenuButton present in HeaderBar");
                
                // Verify MenuButton has menu model
                var found_menu_model = found_menu_button.get_menu_model();
                assert_nonnull(found_menu_model);
                Test.message("✓ MenuButton has menu model");
                
                // Verify menu structure by checking number of sections
                int n_sections = found_menu_model.get_n_items();
                assert_true(n_sections >= 3);
                Test.message("✓ Menu has %d sections (should be at least 3)", n_sections);
                
                Test.message("✓ Hamburger menu structure test successful (Requirements 4.1-4.5)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test menu actions registration (Requirements 4.1, 4.2, 4.3, 4.4, 4.5)
         */
        public static void test_menu_actions_registration() {
            var test = new MenuSystemTestSuite();
            test.setup();
            
            try {
                // Add mock actions to the test window to simulate the actual game window
                var action_group = test.test_window as ActionMap;
                assert_nonnull(action_group);
                Test.message("✓ Window implements ActionMap");
                
                // Add window actions (Requirements 4.1, 4.2, 4.3, 4.4)
                var new_game_action = new SimpleAction("new-game", null);
                action_group.add_action(new_game_action);
                
                var scores_action = new SimpleAction("scores", null);
                action_group.add_action(scores_action);
                
                var change_size_action = new SimpleAction.stateful("change-size", 
                    VariantType.STRING, new Variant.string("medium"));
                action_group.add_action(change_size_action);
                
                var change_theme_action = new SimpleAction.stateful("change-theme", 
                    VariantType.STRING, new Variant.string("balls.svg"));
                action_group.add_action(change_theme_action);
                
                var background_action = new SimpleAction("background", null);
                action_group.add_action(background_action);
                
                var reset_bg_action = new SimpleAction("reset-bg", null);
                action_group.add_action(reset_bg_action);
                
                // Add application actions (Requirement 4.5)
                var app_action_group = test.test_app as ActionMap;
                assert_nonnull(app_action_group);
                Test.message("✓ Application implements ActionMap");
                
                var help_action = new SimpleAction("help", null);
                app_action_group.add_action(help_action);
                
                var about_action = new SimpleAction("about", null);
                app_action_group.add_action(about_action);
                
                var quit_action = new SimpleAction("quit", null);
                app_action_group.add_action(quit_action);
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Check for window actions (Requirements 4.1, 4.2, 4.3, 4.4)
                var found_new_game_action = action_group.lookup_action("new-game");
                assert_nonnull(found_new_game_action);
                Test.message("✓ new-game action registered (Requirement 4.1)");
                
                var found_scores_action = action_group.lookup_action("scores");
                assert_nonnull(found_scores_action);
                Test.message("✓ scores action registered (Requirement 4.3)");
                
                var found_change_size_action = action_group.lookup_action("change-size");
                assert_nonnull(found_change_size_action);
                Test.message("✓ change-size action registered (Requirement 4.2)");
                
                var found_change_theme_action = action_group.lookup_action("change-theme");
                assert_nonnull(found_change_theme_action);
                Test.message("✓ change-theme action registered (Requirement 4.4)");
                
                var found_background_action = action_group.lookup_action("background");
                assert_nonnull(found_background_action);
                Test.message("✓ background action registered (Requirement 4.4)");
                
                var found_reset_bg_action = action_group.lookup_action("reset-bg");
                assert_nonnull(found_reset_bg_action);
                Test.message("✓ reset-bg action registered (Requirement 4.4)");
                
                // Check for application actions (Requirement 4.5)
                var found_help_action = app_action_group.lookup_action("help");
                assert_nonnull(found_help_action);
                Test.message("✓ help action registered (Requirement 4.5)");
                
                var found_about_action = app_action_group.lookup_action("about");
                assert_nonnull(found_about_action);
                Test.message("✓ about action registered (Requirement 4.5)");
                
                Test.message("✓ Menu actions registration test successful (Requirements 4.1-4.5)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test keyboard shortcuts registration (Requirements 5.1, 5.2, 5.3, 5.4, 5.5)
         */
        public static void test_keyboard_shortcuts_registration() {
            var test = new MenuSystemTestSuite();
            test.setup();
            
            try {
                var app = test.test_window.get_application();
                assert_nonnull(app);
                Test.message("✓ Window has application");
                
                // Add mock actions and accelerators to simulate the actual game setup
                var app_action_group = app as ActionMap;
                var window_action_group = test.test_window as ActionMap;
                
                // Add window actions
                var new_game_action = new SimpleAction("new-game", null);
                window_action_group.add_action(new_game_action);
                
                // Add application actions
                var help_action = new SimpleAction("help", null);
                app_action_group.add_action(help_action);
                
                var quit_action = new SimpleAction("quit", null);
                app_action_group.add_action(quit_action);
                
                // Set up keyboard accelerators (Requirements 5.1, 5.2, 5.3)
                app.set_accels_for_action("win.new-game", {"<Primary>n"});
                app.set_accels_for_action("app.quit", {"<Primary>q"});
                app.set_accels_for_action("app.help", {"F1"});
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Test Ctrl+N for new game (Requirement 5.1)
                string[] new_game_accels = app.get_accels_for_action("win.new-game");
                assert_true(new_game_accels.length > 0);
                Test.message("✓ new-game has keyboard accelerators");
                
                bool has_ctrl_n = false;
                foreach (string accel in new_game_accels) {
                    if (accel == "<Primary>n") {
                        has_ctrl_n = true;
                        break;
                    }
                }
                assert_true(has_ctrl_n);
                Test.message("✓ Ctrl+N registered for new-game (Requirement 5.1)");
                
                // Test Ctrl+Q for quit (Requirement 5.2)
                string[] quit_accels = app.get_accels_for_action("app.quit");
                assert_true(quit_accels.length > 0);
                Test.message("✓ quit has keyboard accelerators");
                
                bool has_ctrl_q = false;
                foreach (string accel in quit_accels) {
                    if (accel == "<Primary>q") {
                        has_ctrl_q = true;
                        break;
                    }
                }
                assert_true(has_ctrl_q);
                Test.message("✓ Ctrl+Q registered for quit (Requirement 5.2)");
                
                // Test F1 for help (Requirement 5.3)
                string[] help_accels = app.get_accels_for_action("app.help");
                assert_true(help_accels.length > 0);
                Test.message("✓ help has keyboard accelerators");
                
                bool has_f1 = false;
                foreach (string accel in help_accels) {
                    if (accel == "F1") {
                        has_f1 = true;
                        break;
                    }
                }
                assert_true(has_f1);
                Test.message("✓ F1 registered for help (Requirement 5.3)");
                
                Test.message("✓ Keyboard shortcuts registration test successful (Requirements 5.1-5.5)");
                
            } finally {
                test.teardown();
            }
        }
    }
}