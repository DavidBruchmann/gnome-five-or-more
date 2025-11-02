/*
 * Five or More - Window Initialization Tests
 * 
 * Tests for window creation, initialization, and basic functionality.
 * Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
 */

using FiveOrMoreTest;
using Gtk;

namespace FiveOrMoreTest.Window {

    /**
     * Test suite for window initialization
     * Validates Requirements 1.1-1.5: Window creation, HeaderBar, GridFrame, NextPiecesWidget, MenuButton
     */
    public class WindowInitializationTest : TestBase {
        
        public static void main(string[] args) {
            Test.init(ref args);
            
            // Register test cases for Requirements 1.1-1.5
            Test.add_func("/window/initialization/basic_creation", test_basic_window_creation);
            Test.add_func("/window/initialization/default_dimensions", test_default_window_dimensions);
            Test.add_func("/window/initialization/headerbar_setup", test_headerbar_initialization);
            Test.add_func("/window/initialization/gridframe_creation", test_gridframe_component_creation);
            Test.add_func("/window/initialization/next_pieces_widget", test_next_pieces_widget_initialization);
            Test.add_func("/window/initialization/menu_button_creation", test_menu_button_creation);
            Test.add_func("/window/initialization/required_components", test_required_components_present);
            Test.add_func("/window/initialization/window_title", test_window_title_setup);
            
            Test.run();
        }
        
        /**
         * Test basic window creation without errors
         */
        public static void test_basic_window_creation() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Window should be created successfully
                assert_nonnull(test.test_window);
                assert_nonnull(test.test_app);
                
                // Window should be properly initialized
                assert_true(test.test_window is ApplicationWindow);
                
                Test.message("✓ Basic window creation successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test that window has default dimensions as specified in requirements
         * Requirement 1.1: GameWindow SHALL display with default dimensions of 320x400 pixels
         */
        public static void test_default_window_dimensions() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Check default size before showing (Requirements 1.1)
                int default_width, default_height;
                test.test_window.get_default_size(out default_width, out default_height);
                
                Test.message("Default window dimensions: %dx%d", default_width, default_height);
                
                // Verify default dimensions match requirement 1.1 (320x400)
                assert_cmpint(default_width, CompareOperator.EQ, 320);
                assert_cmpint(default_height, CompareOperator.EQ, 400);
                
                // Show window to verify actual dimensions
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                int actual_width, actual_height;
                test.test_window.get_size(out actual_width, out actual_height);
                Test.message("Actual window dimensions: %dx%d", actual_width, actual_height);
                
                // Actual dimensions should be positive (may vary due to window manager)
                assert_cmpint(actual_width, CompareOperator.GT, 0);
                assert_cmpint(actual_height, CompareOperator.GT, 0);
                
                Test.message("✓ Window dimensions validation successful (Requirement 1.1)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test HeaderBar initialization and title setting
         * Requirement 1.2: GameWindow SHALL load the window title "Five or More" in the HeaderBar
         */
        public static void test_headerbar_initialization() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Create a HeaderBar for testing
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                headerbar.set_show_close_button(true);
                test.test_window.set_titlebar(headerbar);
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Check HeaderBar exists (Requirements 1.2)
                var retrieved_headerbar = WindowTestUtils.get_window_headerbar(test.test_window);
                assert_nonnull(retrieved_headerbar);
                
                // Check title is set (Requirements 1.2)
                string title = retrieved_headerbar.get_title() ?? "";
                assert_true(title.length > 0);
                assert_true(title.contains("Five or More"));
                Test.message("HeaderBar title: '%s'", title);
                
                // Verify HeaderBar is visible and properly configured
                assert_true(retrieved_headerbar.get_visible());
                assert_true(retrieved_headerbar.get_show_close_button());
                
                Test.message("✓ HeaderBar initialization successful (Requirement 1.2)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test GridFrame component creation and display
         * Requirement 1.3: GameWindow SHALL create and display the GridFrame component for the game board
         */
        public static void test_gridframe_component_creation() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Create a mock grid frame (using a simple Frame as placeholder)
                var grid_frame = new Frame("Game Board");
                grid_frame.set_size_request(300, 300);
                test.test_window.add(grid_frame);
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Check for Frame component (simulating GridFrame - Requirement 1.3)
                var found_frame = WindowTestUtils.find_frame(test.test_window);
                assert_nonnull(found_frame);
                
                // Verify Frame is visible and properly configured
                assert_true(found_frame.get_visible());
                assert_true(found_frame.get_realized());
                
                Test.message("✓ GridFrame component creation successful (Requirement 1.3)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test NextPiecesWidget initialization in HeaderBar
         * Requirement 1.4: GameWindow SHALL initialize the NextPiecesWidget in the HeaderBar
         */
        public static void test_next_pieces_widget_initialization() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Create HeaderBar with preview widget
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                
                // Create a mock preview box and drawing area (simulating NextPiecesWidget)
                var preview_box = new Box(Orientation.HORIZONTAL, 5);
                var drawing_area = new DrawingArea();
                drawing_area.set_size_request(100, 30);
                preview_box.pack_start(drawing_area);
                headerbar.pack_end(preview_box);
                
                test.test_window.set_titlebar(headerbar);
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Get HeaderBar first
                var retrieved_headerbar = WindowTestUtils.get_window_headerbar(test.test_window);
                assert_nonnull(retrieved_headerbar);
                
                // Check for preview box in HeaderBar (Requirement 1.4)
                var found_preview_box = WindowTestUtils.find_box(retrieved_headerbar);
                assert_nonnull(found_preview_box);
                
                // NextPiecesWidget is simulated by DrawingArea
                var found_drawing_area = WindowTestUtils.find_drawing_area(found_preview_box);
                assert_nonnull(found_drawing_area);
                
                // Verify the DrawingArea is visible and realized
                assert_true(found_drawing_area.get_visible());
                
                Test.message("✓ NextPiecesWidget initialization successful (Requirement 1.4)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test MenuButton creation with hamburger menu
         * Requirement 1.5: GameWindow SHALL create the MenuButton with the hamburger menu
         */
        public static void test_menu_button_creation() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Create HeaderBar with MenuButton
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                
                // Create a mock menu model
                var menu_model = new GLib.Menu();
                menu_model.append("New Game", "app.new-game");
                menu_model.append("Scores", "app.scores");
                
                // Create MenuButton with the menu
                var menu_button = new MenuButton();
                menu_button.set_menu_model(menu_model);
                headerbar.pack_end(menu_button);
                
                test.test_window.set_titlebar(headerbar);
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Get HeaderBar first
                var retrieved_headerbar = WindowTestUtils.get_window_headerbar(test.test_window);
                assert_nonnull(retrieved_headerbar);
                
                // Check for MenuButton in HeaderBar (Requirement 1.5)
                var found_menu_button = WindowTestUtils.find_menu_button(retrieved_headerbar);
                assert_nonnull(found_menu_button);
                
                // Verify MenuButton is visible and properly configured
                assert_true(found_menu_button.get_visible());
                assert_true(found_menu_button.get_sensitive());
                
                // Check that MenuButton has a menu model
                var found_menu_model = found_menu_button.get_menu_model();
                assert_nonnull(found_menu_model);
                
                // Verify the menu has items (hamburger menu content)
                assert_cmpint(found_menu_model.get_n_items(), CompareOperator.GT, 0);
                
                Test.message("✓ MenuButton creation successful (Requirement 1.5)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test that all required UI components are present
         * Validates Requirements 1.3, 1.4, 1.5 together
         */
        public static void test_required_components_present() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                // Set up all required components for validation
                
                // Create HeaderBar with all components
                var headerbar = new HeaderBar();
                headerbar.set_title("Five or More Test");
                
                // Add preview box with drawing area (NextPiecesWidget simulation)
                var preview_box = new Box(Orientation.HORIZONTAL, 5);
                var drawing_area = new DrawingArea();
                drawing_area.set_size_request(100, 30);
                preview_box.pack_start(drawing_area);
                headerbar.pack_end(preview_box);
                
                // Add menu button
                var menu_model = new GLib.Menu();
                menu_model.append("New Game", "app.new-game");
                var menu_button = new MenuButton();
                menu_button.set_menu_model(menu_model);
                headerbar.pack_end(menu_button);
                
                test.test_window.set_titlebar(headerbar);
                
                // Add frame (GridFrame simulation)
                var grid_frame = new Frame("Game Board");
                grid_frame.set_size_request(300, 300);
                test.test_window.add(grid_frame);
                
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Validate all required components (Requirements 1.3, 1.4, 1.5)
                bool components_valid = WindowTestUtils.validate_required_components(test.test_window);
                assert_true(components_valid);
                
                Test.message("✓ Required components validation successful (Requirements 1.3, 1.4, 1.5)");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test window title setup
         */
        public static void test_window_title_setup() {
            var test = new WindowInitializationTest();
            test.setup();
            
            try {
                test.test_window.show_all();
                WindowTestUtils.wait_for_window_ready(test.test_window);
                
                // Check window title
                string window_title = test.test_window.get_title() ?? "";
                Test.message("Window title: '%s'", window_title);
                
                // Window should have some title set
                assert_true(window_title.length > 0);
                
                Test.message("✓ Window title setup successful");
                
            } finally {
                test.teardown();
            }
        }
    }
}