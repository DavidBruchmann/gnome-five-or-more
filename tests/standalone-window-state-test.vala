/*
 * Five or More - Standalone Window State Management Test
 * 
 * This is a simplified test that can run without the full build system
 * to validate the window state management logic.
 */

using GLib;

// Minimal mock settings for standalone testing
public class StandaloneMockSettings : GLib.Object {
    private HashTable<string, Variant> values;
    
    public StandaloneMockSettings() {
        values = new HashTable<string, Variant>(str_hash, str_equal);
        
        // Set defaults
        values.insert("window-width", new Variant.int32(320));
        values.insert("window-height", new Variant.int32(400));
        values.insert("window-is-maximized", new Variant.boolean(false));
        values.insert("window-is-tiled", new Variant.boolean(false));
    }
    
    public int get_int(string key) {
        if (values.contains(key)) {
            return values.lookup(key).get_int32();
        }
        return 0;
    }
    
    public bool get_boolean(string key) {
        if (values.contains(key)) {
            return values.lookup(key).get_boolean();
        }
        return false;
    }
    
    public void set_int(string key, int value) {
        values.insert(key, new Variant.int32(value));
        print("Set %s = %d\n", key, value);
    }
    
    public void set_boolean(string key, bool value) {
        values.insert(key, new Variant.boolean(value));
        print("Set %s = %s\n", key, value.to_string());
    }
}

// Test validation functions
public class WindowStateValidator {
    public static bool validate_dimensions(StandaloneMockSettings settings) {
        int width = settings.get_int("window-width");
        int height = settings.get_int("window-height");
        
        bool valid = (width > 0 && width <= 4096 && height > 0 && height <= 4096);
        print("Dimension validation: %dx%d -> %s\n", width, height, valid ? "PASS" : "FAIL");
        return valid;
    }
    
    public static bool validate_state_consistency(StandaloneMockSettings settings) {
        bool maximized = settings.get_boolean("window-is-maximized");
        bool tiled = settings.get_boolean("window-is-tiled");
        
        // Cannot be both maximized and tiled
        bool consistent = !(maximized && tiled);
        print("State consistency: maximized=%s, tiled=%s -> %s\n", 
              maximized.to_string(), tiled.to_string(), consistent ? "PASS" : "FAIL");
        return consistent;
    }
}

// Test runner
public class WindowStateTestRunner {
    private int tests_run = 0;
    private int tests_passed = 0;
    
    public void run_test(string test_name, owned TestFunc test_func) {
        tests_run++;
        print("\n=== Running: %s ===\n", test_name);
        
        try {
            if (test_func()) {
                tests_passed++;
                print("✓ %s PASSED\n", test_name);
            } else {
                print("✗ %s FAILED\n", test_name);
            }
        } catch (Error e) {
            print("✗ %s ERROR: %s\n", test_name, e.message);
        }
    }
    
    public void print_summary() {
        print("\n==================================================\n");
        print("Test Summary: %d/%d tests passed\n", tests_passed, tests_run);
        if (tests_passed == tests_run) {
            print("🎉 All tests PASSED!\n");
        } else {
            print("❌ %d tests FAILED\n", tests_run - tests_passed);
        }
        print("==================================================\n");
    }
    
    public bool all_passed() {
        return tests_passed == tests_run;
    }
}

public delegate bool TestFunc();

// Test implementations
public bool test_default_window_dimensions() {
    var settings = new StandaloneMockSettings();
    
    // Test default dimensions (Requirement 2.1)
    int width = settings.get_int("window-width");
    int height = settings.get_int("window-height");
    
    print("Default dimensions: %dx%d\n", width, height);
    
    return (width == 320 && height == 400);
}

public bool test_window_resize_storage() {
    var settings = new StandaloneMockSettings();
    
    // Test resize and storage (Requirement 2.1)
    settings.set_int("window-width", 800);
    settings.set_int("window-height", 600);
    
    int stored_width = settings.get_int("window-width");
    int stored_height = settings.get_int("window-height");
    
    return (stored_width == 800 && stored_height == 600);
}

public bool test_maximize_state_persistence() {
    var settings = new StandaloneMockSettings();
    
    // Test maximization state (Requirement 2.2)
    settings.set_boolean("window-is-maximized", true);
    
    bool is_maximized = settings.get_boolean("window-is-maximized");
    print("Maximized state stored: %s\n", is_maximized.to_string());
    
    return is_maximized;
}

public bool test_dimension_validation() {
    var settings = new StandaloneMockSettings();
    
    // Test valid dimensions
    settings.set_int("window-width", 640);
    settings.set_int("window-height", 480);
    if (!WindowStateValidator.validate_dimensions(settings)) {
        return false;
    }
    
    // Test invalid dimensions
    settings.set_int("window-width", -1);
    settings.set_int("window-height", -1);
    if (WindowStateValidator.validate_dimensions(settings)) {
        return false; // Should have failed validation
    }
    
    return true;
}

public bool test_state_consistency() {
    var settings = new StandaloneMockSettings();
    
    // Test consistent state (not maximized, not tiled)
    settings.set_boolean("window-is-maximized", false);
    settings.set_boolean("window-is-tiled", false);
    if (!WindowStateValidator.validate_state_consistency(settings)) {
        return false;
    }
    
    // Test inconsistent state (both maximized and tiled)
    settings.set_boolean("window-is-maximized", true);
    settings.set_boolean("window-is-tiled", true);
    if (WindowStateValidator.validate_state_consistency(settings)) {
        return false; // Should have failed consistency check
    }
    
    return true;
}

public bool test_settings_integration() {
    var settings = new StandaloneMockSettings();
    
    // Test complete settings workflow (Requirements 2.3, 2.4, 2.5)
    
    // Simulate window resize
    settings.set_int("window-width", 1024);
    settings.set_int("window-height", 768);
    
    // Simulate maximization
    settings.set_boolean("window-is-maximized", true);
    
    // Validate stored state
    bool valid_dims = WindowStateValidator.validate_dimensions(settings);
    bool valid_state = WindowStateValidator.validate_state_consistency(settings);
    
    print("Settings integration: dims=%s, state=%s\n", 
          valid_dims ? "valid" : "invalid", 
          valid_state ? "consistent" : "inconsistent");
    
    return valid_dims && valid_state;
}

// Main function
public int main(string[] args) {
    print("Five or More - Standalone Window State Management Tests\n");
    print("============================================================\n");
    
    var runner = new WindowStateTestRunner();
    
    // Run all tests
    runner.run_test("Default Window Dimensions", test_default_window_dimensions);
    runner.run_test("Window Resize Storage", test_window_resize_storage);
    runner.run_test("Maximize State Persistence", test_maximize_state_persistence);
    runner.run_test("Dimension Validation", test_dimension_validation);
    runner.run_test("State Consistency", test_state_consistency);
    runner.run_test("Settings Integration", test_settings_integration);
    
    // Print results
    runner.print_summary();
    
    return runner.all_passed() ? 0 : 1;
}