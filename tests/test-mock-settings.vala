/*
 * Test for MockSettings implementation
 */

using GLib;

// Copy the essential parts of MockSettings for testing
public class TestMockSettings : GLib.Object {
    private HashTable<string, Variant> values;
    private HashTable<string, Variant> defaults;
    
    public TestMockSettings() {
        values = new HashTable<string, Variant>(str_hash, str_equal);
        defaults = new HashTable<string, Variant>(str_hash, str_equal);
        
        // Set up default values
        defaults.insert("window-width", new Variant.int32(320));
        defaults.insert("window-height", new Variant.int32(400));
        defaults.insert("window-is-maximized", new Variant.boolean(false));
        defaults.insert("window-is-tiled", new Variant.boolean(false));
    }
    
    public int get_int(string key) {
        if (values.contains(key)) {
            return values.lookup(key).get_int32();
        }
        if (defaults.contains(key)) {
            return defaults.lookup(key).get_int32();
        }
        return 0;
    }
    
    public bool get_boolean(string key) {
        if (values.contains(key)) {
            return values.lookup(key).get_boolean();
        }
        if (defaults.contains(key)) {
            return defaults.lookup(key).get_boolean();
        }
        return false;
    }
    
    public bool set_int(string key, int value) {
        values.insert(key, new Variant.int32(value));
        return true;
    }
    
    public bool set_boolean(string key, bool value) {
        values.insert(key, new Variant.boolean(value));
        return true;
    }
    
    public void setup_window_state(int width, int height, bool maximized) {
        set_int("window-width", width);
        set_int("window-height", height);
        set_boolean("window-is-maximized", maximized);
    }
    
    public void clear_all() {
        values.remove_all();
    }
}

public bool test_mock_settings_defaults() {
    var settings = new TestMockSettings();
    
    // Test default values
    int width = settings.get_int("window-width");
    int height = settings.get_int("window-height");
    bool maximized = settings.get_boolean("window-is-maximized");
    
    print("Defaults: %dx%d, maximized=%s\n", width, height, maximized.to_string());
    
    return (width == 320 && height == 400 && !maximized);
}

public bool test_mock_settings_fixtures() {
    var settings = new TestMockSettings();
    
    // Test fixture setup
    settings.setup_window_state(800, 600, false);
    
    int width = settings.get_int("window-width");
    int height = settings.get_int("window-height");
    bool maximized = settings.get_boolean("window-is-maximized");
    
    print("Fixture state: %dx%d, maximized=%s\n", width, height, maximized.to_string());
    
    return (width == 800 && height == 600 && !maximized);
}

public bool test_mock_settings_clear() {
    var settings = new TestMockSettings();
    
    // Set some values
    settings.set_int("window-width", 1024);
    settings.set_boolean("window-is-maximized", true);
    
    // Clear and check defaults are restored
    settings.clear_all();
    
    int width = settings.get_int("window-width");
    bool maximized = settings.get_boolean("window-is-maximized");
    
    print("After clear: width=%d, maximized=%s\n", width, maximized.to_string());
    
    return (width == 320 && !maximized); // Should return to defaults
}

public int main(string[] args) {
    print("MockSettings Implementation Test\n");
    print("================================\n");
    
    int passed = 0;
    int total = 3;
    
    print("\n--- Test 1: Default Values ---\n");
    if (test_mock_settings_defaults()) {
        print("✓ PASSED\n");
        passed++;
    } else {
        print("✗ FAILED\n");
    }
    
    print("\n--- Test 2: Fixture Setup ---\n");
    if (test_mock_settings_fixtures()) {
        print("✓ PASSED\n");
        passed++;
    } else {
        print("✗ FAILED\n");
    }
    
    print("\n--- Test 3: Clear Functionality ---\n");
    if (test_mock_settings_clear()) {
        print("✓ PASSED\n");
        passed++;
    } else {
        print("✗ FAILED\n");
    }
    
    print("\n================================\n");
    print("MockSettings Test Summary: %d/%d passed\n", passed, total);
    
    if (passed == total) {
        print("🎉 All MockSettings tests PASSED!\n");
        return 0;
    } else {
        print("❌ Some MockSettings tests FAILED!\n");
        return 1;
    }
}