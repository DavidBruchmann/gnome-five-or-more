/*
 * Five or More - Window Testing Framework
 * Mock Settings Implementation
 * 
 * This file provides mock settings for isolated testing.
 */

using GLib;

namespace FiveOrMoreTest {

    /**
     * Mock implementation of GLib.Settings for testing
     */
    public class MockSettings : GLib.Object {
        
        private HashTable<string, Variant> values;
        private HashTable<string, Variant> defaults;
        
        public MockSettings() {
            values = new HashTable<string, Variant>(str_hash, str_equal);
            defaults = new HashTable<string, Variant>(str_hash, str_equal);
            
            // Set up default values matching the real application
            set_default_values();
        }
        
        private void set_default_values() {
            defaults.insert("window-width", new Variant.int32(700));
            defaults.insert("window-height", new Variant.int32(540));
            defaults.insert("window-is-maximized", new Variant.boolean(false));
            defaults.insert("size", new Variant.int32(2)); // medium
            defaults.insert("ball-theme", new Variant.string("balls.svg"));
            defaults.insert("background-color", new Variant.string("#7590AE"));
            defaults.insert("move-timeout", new Variant.int32(100));
            defaults.insert("score", new Variant.int32(0));
            defaults.insert("field", new Variant.string(""));
            defaults.insert("preview", new Variant.string(""));
        }
        
        public int get_int(string key) {
            if (values.contains(key)) {
                return values.lookup(key).get_int32();
            }
            
            if (defaults.contains(key)) {
                return defaults.lookup(key).get_int32();
            }
            
            Test.message("Warning: Unknown settings key '%s', returning 0", key);
            return 0;
        }
        
        public bool get_boolean(string key) {
            if (values.contains(key)) {
                return values.lookup(key).get_boolean();
            }
            
            if (defaults.contains(key)) {
                return defaults.lookup(key).get_boolean();
            }
            
            Test.message("Warning: Unknown settings key '%s', returning false", key);
            return false;
        }
        
        public string get_string(string key) {
            if (values.contains(key)) {
                return values.lookup(key).get_string();
            }
            
            if (defaults.contains(key)) {
                return defaults.lookup(key).get_string();
            }
            
            Test.message("Warning: Unknown settings key '%s', returning empty string", key);
            return "";
        }
        
        public bool set_int(string key, int value) {
            values.insert(key, new Variant.int32(value));
            Test.message("MockSettings: Set %s = %d", key, value);
            return true;
        }
        
        public bool set_boolean(string key, bool value) {
            values.insert(key, new Variant.boolean(value));
            Test.message("MockSettings: Set %s = %s", key, value.to_string());
            return true;
        }
        
        public bool set_string(string key, string value) {
            values.insert(key, new Variant.string(value));
            Test.message("MockSettings: Set %s = %s", key, value);
            return true;
        }
        
        public void reset(string key) {
            values.remove(key);
            Test.message("MockSettings: Reset %s to default", key);
        }
        
        public void delay() {
            Test.message("MockSettings: Delay called (no-op in mock)");
        }
        
        public void apply() {
            Test.message("MockSettings: Apply called (no-op in mock)");
        }
        
        /**
         * Set up predefined window state for testing
         */
        public void setup_window_state(int width, int height, bool maximized) {
            set_int("window-width", width);
            set_int("window-height", height);
            set_boolean("window-is-maximized", maximized);
        }
        
        /**
         * Set up predefined theme for testing
         */
        public void setup_theme(string theme_name) {
            set_string("theme", theme_name);
        }
        
        /**
         * Set up predefined background color for testing
         */
        public void setup_background_color(string color) {
            set_string("background-color", color);
        }
        
        /**
         * Clear all values, reverting to defaults
         */
        public void clear_all() {
            values.remove_all();
            Test.message("MockSettings: Cleared all values");
        }
        
        /**
         * Get all current values for debugging
         */
        public void dump_values() {
            Test.message("MockSettings current values:");
            values.foreach((key, value) => {
                Test.message("  %s = %s", key, value.print(false));
            });
        }
    }
    
    /**
     * Test fixtures for predefined window states
     */
    public class WindowStateFixtures : GLib.Object {
        
        /**
         * Default window state fixture
         */
        public static void setup_default_state(MockSettings settings) {
            settings.setup_window_state(320, 400, false);
            settings.set_boolean("window-is-tiled", false);
            Test.message("WindowStateFixtures: Set up default state (320x400, not maximized)");
        }
        
        /**
         * Large window state fixture
         */
        public static void setup_large_window_state(MockSettings settings) {
            settings.setup_window_state(800, 600, false);
            settings.set_boolean("window-is-tiled", false);
            Test.message("WindowStateFixtures: Set up large window state (800x600, not maximized)");
        }
        
        /**
         * Maximized window state fixture
         */
        public static void setup_maximized_state(MockSettings settings) {
            settings.setup_window_state(1024, 768, true);
            settings.set_boolean("window-is-tiled", false);
            Test.message("WindowStateFixtures: Set up maximized state (1024x768, maximized)");
        }
        
        /**
         * Tiled window state fixture
         */
        public static void setup_tiled_state(MockSettings settings) {
            settings.setup_window_state(640, 480, false);
            settings.set_boolean("window-is-tiled", true);
            Test.message("WindowStateFixtures: Set up tiled state (640x480, tiled)");
        }
        
        /**
         * Small window state fixture
         */
        public static void setup_small_window_state(MockSettings settings) {
            settings.setup_window_state(280, 350, false);
            settings.set_boolean("window-is-tiled", false);
            Test.message("WindowStateFixtures: Set up small window state (280x350, not maximized)");
        }
        
        /**
         * Invalid window state fixture for error testing
         */
        public static void setup_invalid_state(MockSettings settings) {
            settings.setup_window_state(-1, -1, false);
            settings.set_boolean("window-is-tiled", false);
            Test.message("WindowStateFixtures: Set up invalid state (-1x-1, for error testing)");
        }
    }
    
    /**
     * Helper methods for Settings state validation
     */
    public class SettingsValidator : GLib.Object {
        
        /**
         * Validate window dimensions are within reasonable bounds
         */
        public static bool validate_window_dimensions(MockSettings settings) {
            int width = settings.get_int("window-width");
            int height = settings.get_int("window-height");
            
            bool valid = (width > 0 && width <= 4096 && height > 0 && height <= 4096);
            Test.message("SettingsValidator: Window dimensions %dx%d are %s", 
                        width, height, valid ? "valid" : "invalid");
            return valid;
        }
        
        /**
         * Validate window state consistency
         */
        public static bool validate_window_state_consistency(MockSettings settings) {
            bool maximized = settings.get_boolean("window-is-maximized");
            bool tiled = settings.get_boolean("window-is-tiled");
            
            // Window cannot be both maximized and tiled simultaneously
            bool consistent = !(maximized && tiled);
            Test.message("SettingsValidator: Window state (maximized=%s, tiled=%s) is %s", 
                        maximized.to_string(), tiled.to_string(), 
                        consistent ? "consistent" : "inconsistent");
            return consistent;
        }
        
        /**
         * Validate all settings have expected types and values
         */
        public static bool validate_all_settings(MockSettings settings) {
            bool all_valid = true;
            
            // Check required integer settings
            string[] int_keys = {"window-width", "window-height", "board-size"};
            foreach (string key in int_keys) {
                int value = settings.get_int(key);
                if (value < 0) {
                    Test.message("SettingsValidator: Invalid %s value: %d", key, value);
                    all_valid = false;
                }
            }
            
            // Check required boolean settings
            string[] bool_keys = {"window-is-maximized", "window-is-tiled"};
            foreach (string key in bool_keys) {
                // Just access to ensure no errors - boolean values are always valid
                settings.get_boolean(key);
            }
            
            // Check required string settings
            string[] string_keys = {"theme", "background-color"};
            foreach (string key in string_keys) {
                string value = settings.get_string(key);
                if (value == "") {
                    Test.message("SettingsValidator: Empty %s value", key);
                    all_valid = false;
                }
            }
            
            Test.message("SettingsValidator: All settings validation %s", 
                        all_valid ? "passed" : "failed");
            return all_valid;
        }
        
        /**
         * Compare two window states for equality
         */
        public static bool compare_window_states(MockSettings settings1, MockSettings settings2) {
            bool width_match = settings1.get_int("window-width") == settings2.get_int("window-width");
            bool height_match = settings1.get_int("window-height") == settings2.get_int("window-height");
            bool maximized_match = settings1.get_boolean("window-is-maximized") == settings2.get_boolean("window-is-maximized");
            bool tiled_match = settings1.get_boolean("window-is-tiled") == settings2.get_boolean("window-is-tiled");
            
            bool states_match = width_match && height_match && maximized_match && tiled_match;
            Test.message("SettingsValidator: Window states %s", states_match ? "match" : "differ");
            return states_match;
        }
    }
    
    /**
     * Settings factory for creating mock or real settings
     */
    public class SettingsFactory : GLib.Object {
        
        private static bool use_mock_settings = false;
        private static MockSettings? mock_instance = null;
        
        public static void enable_mock_settings() {
            use_mock_settings = true;
            mock_instance = new MockSettings();
        }
        
        public static void disable_mock_settings() {
            use_mock_settings = false;
            mock_instance = null;
        }
        
        public static MockSettings get_mock_settings() {
            if (mock_instance == null) {
                mock_instance = new MockSettings();
            }
            return mock_instance;
        }
        
        public static bool is_using_mock() {
            return use_mock_settings;
        }
        
        /**
         * Create a fresh mock settings instance with default values
         */
        public static MockSettings create_fresh_mock_settings() {
            var fresh_settings = new MockSettings();
            WindowStateFixtures.setup_default_state(fresh_settings);
            return fresh_settings;
        }
        
        /**
         * Create mock settings with specific window state
         */
        public static MockSettings create_mock_with_state(int width, int height, bool maximized) {
            var settings = new MockSettings();
            settings.setup_window_state(width, height, maximized);
            return settings;
        }
    }
}