/*
 * Five or More - Accessibility Validation
 * Copyright © 2024 Five or More Contributors
 *
 * Simple validation script to test accessibility functionality
 */

using Gtk;

public class AccessibilityValidation : Object {
    
    public static int main(string[] args) {
        Gtk.init(ref args);
        
        print("Testing AccessibilityProfile system...\n");
        
        // Test 1: Create basic profiles
        print("1. Creating accessibility profiles...\n");
        var high_contrast = new AccessibilityProfile.with_type(AccessibilityProfileType.HIGH_CONTRAST);
        var deuteranopia = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_DEUTERANOPIA);
        var motion_sensitive = new AccessibilityProfile.with_type(AccessibilityProfileType.MOTION_SENSITIVE);
        
        assert(high_contrast.name == "high-contrast");
        assert(deuteranopia.colorblind_friendly == true);
        assert(motion_sensitive.reduce_animations == true);
        print("   ✓ Profile creation successful\n");
        
        // Test 2: Validate profiles
        print("2. Validating profiles...\n");
        var validation = high_contrast.validate();
        assert(validation.is_valid == true);
        print("   ✓ Profile validation successful\n");
        
        // Test 3: Generate color schemes
        print("3. Generating color schemes...\n");
        var scheme = high_contrast.generate_color_scheme();
        assert(scheme != null);
        assert(scheme.high_contrast == true);
        assert(scheme.piece_colors.length >= 7);
        print("   ✓ Color scheme generation successful\n");
        
        // Test 4: Test AccessibilityManager
        print("4. Testing AccessibilityManager...\n");
        var manager = AccessibilityManager.get_instance();
        var profiles = manager.get_builtin_profiles();
        assert(profiles.length >= 6);
        
        var profile = manager.get_profile("high-contrast");
        assert(profile != null);
        print("   ✓ AccessibilityManager functionality successful\n");
        
        // Test 5: Test colorblind schemes
        print("5. Testing colorblind-friendly schemes...\n");
        var colorblind_scheme = manager.get_colorblind_friendly_scheme(AccessibilityProfileType.COLORBLIND_DEUTERANOPIA);
        assert(colorblind_scheme != null);
        assert(colorblind_scheme.colorblind_friendly == true);
        print("   ✓ Colorblind-friendly schemes successful\n");
        
        print("\n✅ All accessibility tests passed!\n");
        print("AccessibilityProfile system is working correctly.\n");
        
        return 0;
    }
}