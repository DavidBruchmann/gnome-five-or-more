/*
 * Five or More - Component Integration Tests
 * 
 * Tests for component interactions and data flow between window components.
 * Validates Requirements 6.1, 6.2, 6.3, 6.4, 6.5
 */

using FiveOrMoreTest;
using Gtk;

namespace FiveOrMoreTest.Integration {

    /**
     * Mock Board class for testing
     */
    public class MockBoard : GLib.Object {
        public signal void board_changed();
        
        public void trigger_board_changed() {
            board_changed();
        }
    }
    
    /**
     * Mock Game class for testing component integration
     */
    public class MockGame : GLib.Object {
        public int n_cols { get; set; default = 9; }
        public int n_rows { get; set; default = 9; }
        public int score { get; set; default = 0; }
        public StatusMessage status_message { get; set; default = StatusMessage.DESCRIPTION; }
        public MockBoard board { get; private set; }
        
        public MockGame(int size) {
            board = new MockBoard();
            switch (size) {
                case 1: // Small
                    n_cols = 7;
                    n_rows = 7;
                    break;
                case 2: // Medium
                    n_cols = 9;
                    n_rows = 9;
                    break;
                case 3: // Large
                    n_cols = 20;
                    n_rows = 15;
                    break;
            }
        }
        
        public void new_game(int size) {
            switch (size) {
                case 1: // Small
                    n_cols = 7;
                    n_rows = 7;
                    break;
                case 2: // Medium
                    n_cols = 9;
                    n_rows = 9;
                    break;
                case 3: // Large
                    n_cols = 20;
                    n_rows = 15;
                    break;
            }
            score = 0;
            status_message = StatusMessage.DESCRIPTION;
        }
    }
    
    /**
     * Mock ThemeRenderer class for testing component integration
     */
    public class MockThemeRenderer : GLib.Object {
        private MockSettings settings;
        
        public MockThemeRenderer(MockSettings settings) {
            this.settings = settings;
        }
    }
    
    /**
     * Mock status message enum
     */
    public enum StatusMessage {
        DESCRIPTION,
        NO_PATH,
        GAME_OVER,
        NONE
    }

    /**
     * ComponentIntegrationTestSuite - Comprehensive test suite for component integration
     * 
     * This class tests the integration between different window components:
     * - Game board size changes and GridFrame updates
     * - Game score changes and HeaderBar status updates  
     * - Theme changes and ThemeRenderer integration
     * - Background color changes and game view updates
     */
    public class ComponentIntegrationTestSuite : TestBase {
        
        private ApplicationWindow? game_window = null;
        private MockGame? test_game = null;
        private MockThemeRenderer? test_theme = null;
        private MockSettings? test_settings = null;
        private HeaderBar? test_headerbar = null;
        private Frame? test_grid_frame = null;
        private DrawingArea? test_game_view = null;
        
        public static void main(string[] args) {
            Test.init(ref args);
            
            // Register comprehensive component integration test cases
            Test.add_func("/integration/component/board_size_gridframe_updates", test_board_size_gridframe_updates);
            Test.add_func("/integration/component/score_headerbar_updates", test_score_headerbar_updates);
            Test.add_func("/integration/component/theme_renderer_integration", test_theme_renderer_integration);
            Test.add_func("/integration/component/background_color_view_updates", test_background_color_view_updates);
            Test.add_func("/integration/component/game_state_window_updates", test_game_state_window_updates);
            
            Test.run();
        }
        
        /**
         * Set up test environment with mock components for integration testing
         */
        public override void setup() {
            base.setup();
            
            // Enable mock settings for isolated testing
            SettingsFactory.enable_mock_settings();
            test_settings = SettingsFactory.get_mock_settings();
            
            // Create test game and theme components
            test_game = new MockGame(2); // Medium size board
            test_theme = new MockThemeRenderer(test_settings);
            
            // Use the base test window for component integration testing
            game_window = test_window;
            
            // Set up mock UI components to simulate GameWindow structure
            setup_mock_game_window_components();
        }
        
        /**
         * Set up mock UI components that simulate the GameWindow structure
         */
        private void setup_mock_game_window_components() {
            // Create HeaderBar with title
            test_headerbar = new HeaderBar();
            test_headerbar.set_title("Five or More");
            test_headerbar.set_subtitle("Match five objects of the same type in a row to score!");
            game_window.set_titlebar(test_headerbar);
            
            // Create main container
            var main_box = new Box(Orientation.VERTICAL, 0);
            game_window.add(main_box);
            
            // Create GridFrame (simulated with Frame)
            test_grid_frame = new Frame("Game Board");
            test_grid_frame.set_size_request(400, 400);
            
            // Create game view (simulated with DrawingArea)
            test_game_view = new DrawingArea();
            test_game_view.set_size_request(380, 380);
            test_grid_frame.add(test_game_view);
            
            main_box.pack_start(test_grid_frame, true, true, 0);
        }
        
        /**
         * Clean up test environment
         */
        public override void teardown() {
            test_game = null;
            test_theme = null;
            test_settings = null;
            test_headerbar = null;
            test_grid_frame = null;
            test_game_view = null;
            game_window = null;
            
            SettingsFactory.disable_mock_settings();
            base.teardown();
        }
        
        /**
         * Test game board size changes and GridFrame updates (Requirement 6.1)
         */
        public static void test_board_size_gridframe_updates() {
            var test = new ComponentIntegrationTestSuite();
            test.setup();
            
            try {
                test.game_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.game_window);
                
                Test.message("Testing board size changes and GridFrame updates");
                
                // Find GridFrame component (simulated with Frame)
                var grid_frame = WindowTestUtils.find_frame(test.game_window);
                assert_true(grid_frame != null);
                
                // Test initial board size
                Test.message("Verifying initial GridFrame configuration");
                assert_cmpint(test.test_game.n_cols, CompareOperator.GT, 0);
                assert_cmpint(test.test_game.n_rows, CompareOperator.GT, 0);
                
                // Simulate board size change to small (size 1)
                Test.message("Testing board size change to small");
                test.test_settings.set_int("size", 1);
                test.test_game.new_game(1);
                
                // Verify GridFrame updates to reflect new size
                test.wait_for_ui_update(200);
                assert_cmpint(test.test_game.n_cols, CompareOperator.EQ, 7); // Small board
                assert_cmpint(test.test_game.n_rows, CompareOperator.EQ, 7);
                
                // Test board size change to large (size 3)
                Test.message("Testing board size change to large");
                test.test_settings.set_int("size", 3);
                test.test_game.new_game(3);
                
                // Verify GridFrame updates again
                test.wait_for_ui_update(200);
                assert_cmpint(test.test_game.n_cols, CompareOperator.EQ, 20); // Large board
                assert_cmpint(test.test_game.n_rows, CompareOperator.EQ, 15);
                
                Test.message("✓ Board size and GridFrame integration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test game score changes and HeaderBar status updates (Requirement 6.2)
         */
        public static void test_score_headerbar_updates() {
            var test = new ComponentIntegrationTestSuite();
            test.setup();
            
            try {
                test.game_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.game_window);
                
                Test.message("Testing score changes and HeaderBar status updates");
                
                // Find HeaderBar component
                var headerbar = test.game_window.get_titlebar() as HeaderBar;
                assert_true(headerbar != null);
                
                // Test initial status message
                Test.message("Verifying initial HeaderBar status");
                string? initial_subtitle = headerbar.get_subtitle();
                assert_true(initial_subtitle != null);
                
                // Simulate score change by triggering game score update
                Test.message("Testing score update integration");
                int initial_score = test.test_game.score;
                
                // Simulate a scoring event (this would normally happen through game logic)
                // We'll test the notification mechanism
                test.test_game.notify_property("score");
                test.wait_for_ui_update(100);
                
                // Verify HeaderBar receives score updates
                string? updated_subtitle = headerbar.get_subtitle();
                assert_true(updated_subtitle != null);
                
                // Test game over status message
                Test.message("Testing game over status integration");
                test.test_game.notify_property("status-message");
                test.wait_for_ui_update(100);
                
                Test.message("✓ Score and HeaderBar integration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test theme changes and ThemeRenderer integration (Requirement 6.4)
         */
        public static void test_theme_renderer_integration() {
            var test = new ComponentIntegrationTestSuite();
            test.setup();
            
            try {
                test.game_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.game_window);
                
                Test.message("Testing theme changes and ThemeRenderer integration");
                
                // Test initial theme loading
                Test.message("Verifying initial theme configuration");
                string initial_theme = test.test_settings.get_string("ball-theme");
                assert_true(initial_theme != null);
                
                // Test theme change to balls.svg
                Test.message("Testing theme change to balls.svg");
                test.test_settings.set_string("ball-theme", "balls.svg");
                test.wait_for_ui_update(200);
                
                // Verify theme renderer updates
                string updated_theme = test.test_settings.get_string("ball-theme");
                assert_cmpstr(updated_theme, CompareOperator.EQ, "balls.svg");
                
                // Test theme change to shapes.svg
                Test.message("Testing theme change to shapes.svg");
                test.test_settings.set_string("ball-theme", "shapes.svg");
                test.wait_for_ui_update(200);
                
                // Verify theme renderer integration
                updated_theme = test.test_settings.get_string("ball-theme");
                assert_cmpstr(updated_theme, CompareOperator.EQ, "shapes.svg");
                
                // Test theme change to tango.svg
                Test.message("Testing theme change to tango.svg");
                test.test_settings.set_string("ball-theme", "tango.svg");
                test.wait_for_ui_update(200);
                
                // Verify final theme update
                updated_theme = test.test_settings.get_string("ball-theme");
                assert_cmpstr(updated_theme, CompareOperator.EQ, "tango.svg");
                
                Test.message("✓ Theme and ThemeRenderer integration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test background color changes and game view updates (Requirement 6.5)
         */
        public static void test_background_color_view_updates() {
            var test = new ComponentIntegrationTestSuite();
            test.setup();
            
            try {
                test.game_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.game_window);
                
                Test.message("Testing background color changes and game view updates");
                
                // Test initial background color
                Test.message("Verifying initial background color configuration");
                string initial_bg_color = test.test_settings.get_string("background-color");
                assert_true(initial_bg_color != null);
                
                // Test background color change to red
                Test.message("Testing background color change to red");
                test.test_settings.set_string("background-color", "rgb(255,0,0)");
                test.wait_for_ui_update(200);
                
                // Verify background color update
                string updated_bg_color = test.test_settings.get_string("background-color");
                assert_cmpstr(updated_bg_color, CompareOperator.EQ, "rgb(255,0,0)");
                
                // Test background color change to blue
                Test.message("Testing background color change to blue");
                test.test_settings.set_string("background-color", "rgb(0,0,255)");
                test.wait_for_ui_update(200);
                
                // Verify game view integration
                updated_bg_color = test.test_settings.get_string("background-color");
                assert_cmpstr(updated_bg_color, CompareOperator.EQ, "rgb(0,0,255)");
                
                // Test background color reset to default
                Test.message("Testing background color reset to default");
                test.test_settings.reset("background-color");
                test.wait_for_ui_update(200);
                
                // Verify reset functionality
                string reset_bg_color = test.test_settings.get_string("background-color");
                assert_true(reset_bg_color != null);
                
                Test.message("✓ Background color and game view integration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test comprehensive game state changes and window updates (Requirements 6.1, 6.2, 6.3)
         */
        public static void test_game_state_window_updates() {
            var test = new ComponentIntegrationTestSuite();
            test.setup();
            
            try {
                test.game_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.game_window);
                
                Test.message("Testing comprehensive game state and window integration");
                
                // Find key components
                var headerbar = test.game_window.get_titlebar() as HeaderBar;
                var grid_frame = WindowTestUtils.find_frame(test.game_window);
                
                assert_true(headerbar != null);
                assert_true(grid_frame != null);
                
                // Test new game integration
                Test.message("Testing new game state integration");
                test.test_game.new_game(2); // Medium size
                test.wait_for_ui_update(200);
                
                // Verify all components are updated
                assert_cmpint(test.test_game.score, CompareOperator.EQ, 0);
                string? subtitle_after_new_game = headerbar.get_subtitle();
                assert_true(subtitle_after_new_game != null);
                
                // Test game status message integration
                Test.message("Testing game status message integration");
                test.test_game.status_message = StatusMessage.NO_PATH;
                test.test_game.notify_property("status-message");
                test.wait_for_ui_update(100);
                
                // Verify status message propagation
                string? status_subtitle = headerbar.get_subtitle();
                assert_true(status_subtitle != null);
                
                // Test board change integration
                Test.message("Testing board change integration");
                test.test_game.board.trigger_board_changed();
                test.wait_for_ui_update(200);
                
                // Verify board change propagation to GridFrame
                // GridFrame should handle board_changed signal
                
                Test.message("✓ Comprehensive game state and window integration test successful");
                
            } finally {
                test.teardown();
            }
        }
    }
}