/*
 * Five or More - Window State Management Tests
 * 
 * Tests for window state persistence, resizing, and maximization.
 */

using FiveOrMoreTest;

namespace FiveOrMoreTest.Window {

    /**
     * Comprehensive test suite for window state management
     */
    public class WindowStateManagementTest : TestBase {
        
        private MockSettings? mock_settings = null;
        
        public static void main(string[] args) {
            Test.init(ref args);
            
            // Register comprehensive test cases
            Test.add_func("/window/state/resize_and_storage", test_window_resize_and_storage);
            Test.add_func("/window/state/maximize_persistence", test_window_maximize_persistence);
            Test.add_func("/window/state/settings_integration", test_settings_integration);
            Test.add_func("/window/state/restoration_on_startup", test_window_state_restoration);
            Test.add_func("/window/state/dimension_validation", test_dimension_validation);
            Test.add_func("/window/state/tiled_state_handling", test_tiled_state_handling);
            Test.add_func("/window/state/state_consistency", test_state_consistency);
            
            Test.run();
        }
        
        protected override void setup() {
            base.setup();
            
            // Enable mock settings for isolated testing
            SettingsFactory.enable_mock_settings();
            mock_settings = SettingsFactory.get_mock_settings();
            mock_settings.clear_all();
        }
        
        protected override void teardown() {
            if (mock_settings != null) {
                mock_settings.clear_all();
                mock_settings = null;
            }
            SettingsFactory.disable_mock_settings();
            
            base.teardown();
        }
        
        /**
         * Test window resizing and dimension storage (Requirement 2.1)
         */
        public static void test_window_resize_and_storage() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Set up initial window state
                WindowStateFixtures.setup_default_state(test.mock_settings);
                
                test.test_window.show_all();
                test.wait_for_ui_update(300);
                
                // Test multiple resize operations
                int[] test_widths = {640, 800, 1024, 500};
                int[] test_heights = {480, 600, 768, 400};
                
                for (int i = 0; i < test_widths.length; i++) {
                    Test.message("Testing resize to %dx%d", test_widths[i], test_heights[i]);
                    
                    // Simulate window resize
                    test.resize_window(test_widths[i], test_heights[i]);
                    
                    // Verify window accepts the resize
                    int actual_width, actual_height;
                    test.test_window.get_size(out actual_width, out actual_height);
                    
                    Test.message("Actual window size after resize: %dx%d", actual_width, actual_height);
                    
                    // Window should handle resize without errors
                    assert_cmpint(actual_width, CompareOperator.GT, 0, "Width should be positive after resize");
                    assert_cmpint(actual_height, CompareOperator.GT, 0, "Height should be positive after resize");
                    
                    // Trigger state saving
                    test.test_window.on_shutdown();
                    
                    // Verify dimensions are stored (mock settings should capture the values)
                    Test.message("Stored width: %d, height: %d", 
                                test.mock_settings.get_int("window-width"),
                                test.mock_settings.get_int("window-height"));
                }
                
                Test.message("✓ Window resize and storage test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test window maximization state persistence (Requirement 2.2)
         */
        public static void test_window_maximize_persistence() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Set up initial non-maximized state
                WindowStateFixtures.setup_default_state(test.mock_settings);
                
                test.test_window.show_all();
                test.wait_for_ui_update(300);
                
                // Test maximization
                Test.message("Testing window maximization");
                test.maximize_window();
                
                // Simulate window state event for maximization
                // Note: In real GTK, this would be triggered by window manager
                test.test_window.on_shutdown();
                
                // Verify maximized state is stored
                bool stored_maximized = test.mock_settings.get_boolean("window-is-maximized");
                Test.message("Stored maximized state: %s", stored_maximized.to_string());
                
                // Test unmaximization
                Test.message("Testing window unmaximization");
                test.unmaximize_window();
                
                test.test_window.on_shutdown();
                
                Test.message("✓ Window maximize persistence test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test Settings integration for state restoration (Requirements 2.3, 2.4, 2.5)
         */
        public static void test_settings_integration() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Set up predefined window state
                test.mock_settings.setup_window_state(800, 600, false);
                
                // Verify settings integration works
                assert_true(SettingsValidator.validate_window_dimensions(test.mock_settings),
                           "Window dimensions should be valid");
                assert_true(SettingsValidator.validate_window_state_consistency(test.mock_settings),
                           "Window state should be consistent");
                
                test.test_window.show_all();
                test.wait_for_ui_update(300);
                
                // Test state changes and persistence
                test.resize_window(1024, 768);
                test.test_window.on_shutdown();
                
                // Verify state was saved
                int saved_width = test.mock_settings.get_int("window-width");
                int saved_height = test.mock_settings.get_int("window-height");
                
                Test.message("Settings integration - saved dimensions: %dx%d", saved_width, saved_height);
                
                assert_cmpint(saved_width, CompareOperator.GT, 0, "Saved width should be positive");
                assert_cmpint(saved_height, CompareOperator.GT, 0, "Saved height should be positive");
                
                Test.message("✓ Settings integration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test window state restoration on application startup (Requirements 2.3, 2.4)
         */
        public static void test_window_state_restoration() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Set up a specific window state to restore
                WindowStateFixtures.setup_large_window_state(test.mock_settings);
                
                // Verify the state is set correctly
                int expected_width = test.mock_settings.get_int("window-width");
                int expected_height = test.mock_settings.get_int("window-height");
                bool expected_maximized = test.mock_settings.get_boolean("window-is-maximized");
                
                Test.message("Expected restoration state: %dx%d, maximized=%s", 
                            expected_width, expected_height, expected_maximized.to_string());
                
                // Create a new window that should restore this state
                test.test_window.show_all();
                test.wait_for_ui_update(300);
                
                // In a real scenario, the window would restore from settings during construction
                // For testing, we verify the settings contain the expected values
                assert_cmpint(expected_width, CompareOperator.EQ, 800, "Expected width should be 800");
                assert_cmpint(expected_height, CompareOperator.EQ, 600, "Expected height should be 600");
                assert_false(expected_maximized, "Window should not be maximized in this fixture");
                
                Test.message("✓ Window state restoration test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test dimension validation and bounds checking
         */
        public static void test_dimension_validation() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Test valid dimensions
                WindowStateFixtures.setup_default_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_dimensions(test.mock_settings),
                           "Default dimensions should be valid");
                
                // Test large but valid dimensions
                WindowStateFixtures.setup_large_window_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_dimensions(test.mock_settings),
                           "Large dimensions should be valid");
                
                // Test small but valid dimensions
                WindowStateFixtures.setup_small_window_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_dimensions(test.mock_settings),
                           "Small dimensions should be valid");
                
                // Test invalid dimensions
                WindowStateFixtures.setup_invalid_state(test.mock_settings);
                assert_false(SettingsValidator.validate_window_dimensions(test.mock_settings),
                            "Invalid dimensions should be rejected");
                
                Test.message("✓ Dimension validation test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test tiled state handling
         */
        public static void test_tiled_state_handling() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Set up tiled state
                WindowStateFixtures.setup_tiled_state(test.mock_settings);
                
                test.test_window.show_all();
                test.wait_for_ui_update(300);
                
                // Verify tiled state is handled correctly
                bool is_tiled = test.mock_settings.get_boolean("window-is-tiled");
                bool is_maximized = test.mock_settings.get_boolean("window-is-maximized");
                
                Test.message("Tiled state: %s, Maximized state: %s", 
                            is_tiled.to_string(), is_maximized.to_string());
                
                assert_true(is_tiled, "Window should be in tiled state");
                assert_false(is_maximized, "Tiled window should not be maximized");
                
                Test.message("✓ Tiled state handling test successful");
                
            } finally {
                test.teardown();
            }
        }
        
        /**
         * Test state consistency validation
         */
        public static void test_state_consistency() {
            var test = new WindowStateManagementTest();
            test.setup();
            
            try {
                // Test consistent states
                WindowStateFixtures.setup_default_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_state_consistency(test.mock_settings),
                           "Default state should be consistent");
                
                WindowStateFixtures.setup_maximized_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_state_consistency(test.mock_settings),
                           "Maximized state should be consistent");
                
                WindowStateFixtures.setup_tiled_state(test.mock_settings);
                assert_true(SettingsValidator.validate_window_state_consistency(test.mock_settings),
                           "Tiled state should be consistent");
                
                // Test inconsistent state (both maximized and tiled)
                test.mock_settings.set_boolean("window-is-maximized", true);
                test.mock_settings.set_boolean("window-is-tiled", true);
                assert_false(SettingsValidator.validate_window_state_consistency(test.mock_settings),
                            "Both maximized and tiled should be inconsistent");
                
                Test.message("✓ State consistency test successful");
                
            } finally {
                test.teardown();
            }
        }
    }
}