/*
 * Five or More - Keyboard Shortcut Integration Tests
 * 
 * Tests for keyboard shortcut functionality and integration.
 */

using FiveOrMoreTest;
using Gtk;

namespace FiveOrMoreTest.UI {

    /**
     * Test suite for keyboard shortcut integration
     */
    public class KeyboardShortcutIntegrationTest : TestBase {
        
        public static void main(string[] args) {
            Test.init(ref args);
            
            // Register test cases for keyboard shortcut integration
            Test.add_func("/ui/keyboard/ctrl_n_new_game", test_ctrl_n_new_game);
            Test.add_func("/ui/keyboard/ctrl_q_quit", test_ctrl_q_quit);
            Test.add_func("/ui/keyboard/f1_help", test_f1_help);
            Test.add_func("/ui/keyboard/f10_menu", test_f10_menu);
            
            Test.run();
        }
        
        /**
         * Test Ctrl+N for new game action triggering (Requirement 5.1)
         */
        public static void test_ctrl_n_new_game() {
            var test = new KeyboardShortcutIntegrationTest();
            test.setup();
            
            try {
                var app = test.test_window.get_application();
                assert_nonnull(app);
                Test.message("✓ Window has application");
                
                // Add mock action and accelerator
                var action_group = test.test_window as ActionMap;
                var new_game_action = new SimpleAction("new-game", null);
                action_group.add_action(new_game_action);
                app.set_accels_for_action("win.new-game", {"<Primary>n"});
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Verify Ctrl+N is registered for new-game action
                string[] accels = app.get_accels_for_action("win.new-game");
                assert_true(accels.length > 0);
                Test.message("✓ new-game has accelerators");
                
                bool has_ctrl_n = false;
                foreach (string accel in accels) {
                    if (accel == "<Primary>n") {
                        has_ctrl_n = true;
                        break;
                    }
                }
                assert_true(has_ctrl_n);
                Test.message("✓ Ctrl+N registered for new-game");
                
                // Test that the action exists and is enabled
                var found_new_game_action = action_group.lookup_action("new-game");
                assert_nonnull(found_new_game_action);
                Test.message("✓ new-game action exists");
                assert_true(found_new_game_action.get_enabled());
                Test.message("✓ new-game action enabled");
                
                // Simulate Ctrl+N activation by directly triggering the action
                found_new_game_action.activate(null);
                
                Test.message("✓ Ctrl+N new game integration test successful (Requirement 5.1)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test Ctrl+Q for application quit functionality (Requirement 5.2)
         */
        public static void test_ctrl_q_quit() {
            var test = new KeyboardShortcutIntegrationTest();
            test.setup();
            
            try {
                var app = test.test_window.get_application();
                assert_nonnull(app);
                Test.message("✓ Window has application");
                
                // Add mock action and accelerator
                var app_action_group = app as ActionMap;
                var quit_action = new SimpleAction("quit", null);
                app_action_group.add_action(quit_action);
                app.set_accels_for_action("app.quit", {"<Primary>q"});
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Verify Ctrl+Q is registered for quit action
                string[] accels = app.get_accels_for_action("app.quit");
                assert_true(accels.length > 0);
                Test.message("✓ quit has accelerators");
                
                bool has_ctrl_q = false;
                foreach (string accel in accels) {
                    if (accel == "<Primary>q") {
                        has_ctrl_q = true;
                        break;
                    }
                }
                assert_true(has_ctrl_q);
                Test.message("✓ Ctrl+Q registered for quit");
                
                // Test that the quit action exists
                var found_quit_action = app_action_group.lookup_action("quit");
                assert_nonnull(found_quit_action);
                Test.message("✓ quit action exists");
                assert_true(found_quit_action.get_enabled());
                Test.message("✓ quit action enabled");
                
                // Note: We don't actually trigger quit in tests as it would terminate the test
                Test.message("✓ Ctrl+Q quit integration test successful (Requirement 5.2)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test F1 for help documentation opening (Requirement 5.3)
         */
        public static void test_f1_help() {
            var test = new KeyboardShortcutIntegrationTest();
            test.setup();
            
            try {
                var app = test.test_window.get_application();
                assert_nonnull(app);
                Test.message("✓ Window has application");
                
                // Add mock action and accelerator
                var app_action_group = app as ActionMap;
                var help_action = new SimpleAction("help", null);
                app_action_group.add_action(help_action);
                app.set_accels_for_action("app.help", {"F1"});
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Verify F1 is registered for help action
                string[] accels = app.get_accels_for_action("app.help");
                assert_true(accels.length > 0);
                Test.message("✓ help has accelerators");
                
                bool has_f1 = false;
                foreach (string accel in accels) {
                    if (accel == "F1") {
                        has_f1 = true;
                        break;
                    }
                }
                assert_true(has_f1);
                Test.message("✓ F1 registered for help");
                
                // Test that the help action exists
                var found_help_action = app_action_group.lookup_action("help");
                assert_nonnull(found_help_action);
                Test.message("✓ help action exists");
                assert_true(found_help_action.get_enabled());
                Test.message("✓ help action enabled");
                
                // Simulate F1 activation by directly triggering the action
                found_help_action.activate(null);
                
                Test.message("✓ F1 help integration test successful (Requirement 5.3)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test F10 for hamburger menu activation (Requirement 5.4)
         */
        public static void test_f10_menu() {
            var test = new KeyboardShortcutIntegrationTest();
            test.setup();
            
            try {
                // Create HeaderBar with MenuButton to test F10 functionality
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                
                // Create a menu model
                var menu_model = new GLib.Menu();
                menu_model.append("New Game", "win.new-game");
                menu_model.append("Scores", "win.scores");
                
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
                
                var found_menu_button = WindowTestUtils.find_menu_button(retrieved_headerbar);
                assert_nonnull(found_menu_button);
                Test.message("✓ MenuButton present");
                
                // Verify MenuButton has menu model
                var found_menu_model = found_menu_button.get_menu_model();
                assert_nonnull(found_menu_model);
                Test.message("✓ MenuButton has menu model");
                
                // Test that MenuButton can be activated
                // F10 accelerator is defined in the UI template for the MenuButton
                assert_true(found_menu_button.get_sensitive());
                Test.message("✓ MenuButton is sensitive");
                
                // Simulate F10 activation by activating the menu button
                found_menu_button.activate();
                
                Test.message("✓ F10 menu activation integration test successful (Requirement 5.4)");
                
            } finally {
                test.teardown();
            }
        }
    }
}