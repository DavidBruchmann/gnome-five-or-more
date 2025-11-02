/*
 * Five or More - Accessibility Profile Tests
 * Copyright © 2024 Five or More Contributors
 *
 * This game is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

using Gtk;

/**
 * Test suite for AccessibilityProfile system
 */
public class AccessibilityProfileTests : Object {
    
    public static void run_tests(ref unowned string[] args) {
        Test.init(ref args);
        
        Test.add_func("/accessibility/profile_creation", test_profile_creation);
        Test.add_func("/accessibility/colorblind_profiles", test_colorblind_profiles);
        Test.add_func("/accessibility/high_contrast_profile", test_high_contrast_profile);
        Test.add_func("/accessibility/motion_sensitive_profile", test_motion_sensitive_profile);
        Test.add_func("/accessibility/profile_validation", test_profile_validation);
        Test.add_func("/accessibility/color_scheme_generation", test_color_scheme_generation);
        Test.add_func("/accessibility/manager_functionality", test_manager_functionality);
        
        Test.run();
    }
    
    /**
     * Test basic profile creation
     */
    private static void test_profile_creation() {
        var profile = new AccessibilityProfile.with_type(AccessibilityProfileType.HIGH_CONTRAST);
        
        assert(profile.name == "high-contrast");
        assert(profile.profile_type == AccessibilityProfileType.HIGH_CONTRAST);
        assert(profile.high_contrast_enabled == true);
        assert(profile.contrast_level == ContrastLevel.HIGH);
    }
    
    /**
     * Test colorblind-friendly profiles
     */
    private static void test_colorblind_profiles() {
        // Test deuteranopia profile
        var deuteranopia = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_DEUTERANOPIA);
        assert(deuteranopia.colorblind_friendly == true);
        assert(deuteranopia.colorblind_type == "deuteranopia");
        assert(deuteranopia.preferred_colors != null);
        assert(deuteranopia.preferred_colors.length >= 7);
        
        // Test protanopia profile
        var protanopia = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_PROTANOPIA);
        assert(protanopia.colorblind_friendly == true);
        assert(protanopia.colorblind_type == "protanopia");
        
        // Test tritanopia profile
        var tritanopia = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_TRITANOPIA);
        assert(tritanopia.colorblind_friendly == true);
        assert(tritanopia.colorblind_type == "tritanopia");
    }
    
    /**
     * Test high contrast profile
     */
    private static void test_high_contrast_profile() {
        var profile = new AccessibilityProfile.with_type(AccessibilityProfileType.HIGH_CONTRAST);
        
        assert(profile.high_contrast_enabled == true);
        assert(profile.contrast_level == ContrastLevel.HIGH);
        assert(profile.border_width_multiplier >= 2);
        assert(profile.enhanced_focus_indicators == true);
        
        // Validate the profile
        var validation = profile.validate();
        assert(validation.is_valid == true);
    }
    
    /**
     * Test motion sensitive profile
     */
    private static void test_motion_sensitive_profile() {
        var profile = new AccessibilityProfile.with_type(AccessibilityProfileType.MOTION_SENSITIVE);
        
        assert(profile.motion_sensitivity == MotionSensitivity.MINIMAL);
        assert(profile.reduce_animations == true);
        assert(profile.disable_transitions == true);
        assert(profile.animation_speed_multiplier <= 1.0);
    }
    
    /**
     * Test profile validation
     */
    private static void test_profile_validation() {
        var profile = new AccessibilityProfile();
        profile.name = "test-profile";
        profile.display_name = "Test Profile";
        profile.border_width_multiplier = 2;
        profile.animation_speed_multiplier = 0.5;
        profile.opacity_adjustment = 0.1;
        profile.background_color = "#FFFFFF";
        profile.border_color = "#000000";
        
        var validation = profile.validate();
        assert(validation.is_valid == true);
        
        // Test invalid settings
        profile.border_width_multiplier = 10; // Too high
        validation = profile.validate();
        assert(validation.is_valid == false);
        assert(validation.errors.length > 0);
    }
    
    /**
     * Test color scheme generation from profiles
     */
    private static void test_color_scheme_generation() {
        var profile = new AccessibilityProfile.with_type(AccessibilityProfileType.HIGH_CONTRAST);
        var scheme = profile.generate_color_scheme();
        
        assert(scheme != null);
        assert(scheme.name.has_prefix("accessibility-"));
        assert(scheme.high_contrast == true);
        assert(scheme.piece_colors.length >= 7);
        assert(scheme.border_width >= 5);
        
        // Test colorblind profile
        var colorblind_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_DEUTERANOPIA);
        var colorblind_scheme = colorblind_profile.generate_color_scheme();
        
        assert(colorblind_scheme.colorblind_friendly == true);
        assert(colorblind_scheme.accessibility_profile == "colorblind-deuteranopia");
    }
    
    /**
     * Test AccessibilityManager functionality
     */
    private static void test_manager_functionality() {
        var manager = AccessibilityManager.get_instance();
        
        // Test getting built-in profiles
        var builtin_profiles = manager.get_builtin_profiles();
        assert(builtin_profiles.length >= 6); // Should have at least 6 built-in profiles
        
        // Test getting specific profiles
        var high_contrast = manager.get_profile("high-contrast");
        assert(high_contrast != null);
        assert(high_contrast.profile_type == AccessibilityProfileType.HIGH_CONTRAST);
        
        var deuteranopia = manager.get_profile("colorblind-deuteranopia");
        assert(deuteranopia != null);
        assert(deuteranopia.colorblind_friendly == true);
        
        // Test setting current profile
        var success = manager.set_current_profile("high-contrast");
        assert(success == true);
        
        var current = manager.get_current_profile();
        assert(current != null);
        assert(current.name == "high-contrast");
        
        // Test colorblind scheme generation
        var scheme = manager.get_colorblind_friendly_scheme(AccessibilityProfileType.COLORBLIND_PROTANOPIA);
        assert(scheme != null);
        assert(scheme.colorblind_friendly == true);
    }
}

/**
 * Main test runner
 */
public static int main(string[] args) {
    Gtk.init(ref args);
    AccessibilityProfileTests.run_tests(ref args);
    return 0;
}