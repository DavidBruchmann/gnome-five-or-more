/*
 * Five or More - Accessibility Manager
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

/**
 * Manages accessibility profiles and provides accessibility-optimized color schemes
 */
public class AccessibilityManager : Object {
    private static AccessibilityManager? instance = null;
    private HashTable<string, AccessibilityProfile> builtin_profiles;
    private HashTable<string, AccessibilityProfile> user_profiles;
    private string user_profiles_dir;
    private AccessibilityProfile? current_profile;
    
    // Signals for profile changes
    public signal void profile_changed(AccessibilityProfile? old_profile, AccessibilityProfile new_profile);
    public signal void profile_created(AccessibilityProfile profile);
    public signal void profile_deleted(string profile_name);
    
    construct {
        builtin_profiles = new HashTable<string, AccessibilityProfile>(str_hash, str_equal);
        user_profiles = new HashTable<string, AccessibilityProfile>(str_hash, str_equal);
        
        // Set up user profiles directory
        user_profiles_dir = Path.build_filename(
            Environment.get_user_config_dir(),
            "five-or-more",
            "accessibility-profiles"
        );
        
        initialize_builtin_profiles();
        load_user_profiles();
        
        // Set default profile
        current_profile = get_profile("none");
    }
    
    /**
     * Get singleton instance
     */
    public static AccessibilityManager get_instance() {
        if (instance == null) {
            instance = new AccessibilityManager();
        }
        return instance;
    }
    
    /**
     * Initialize built-in accessibility profiles
     */
    private void initialize_builtin_profiles() {
        // Standard profile (no accessibility modifications)
        var none_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.NONE);
        builtin_profiles.insert("none", none_profile);
        
        // High contrast profile
        var high_contrast_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.HIGH_CONTRAST);
        builtin_profiles.insert("high-contrast", high_contrast_profile);
        
        // Colorblind profiles
        var deuteranopia_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_DEUTERANOPIA);
        builtin_profiles.insert("colorblind-deuteranopia", deuteranopia_profile);
        
        var protanopia_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_PROTANOPIA);
        builtin_profiles.insert("colorblind-protanopia", protanopia_profile);
        
        var tritanopia_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.COLORBLIND_TRITANOPIA);
        builtin_profiles.insert("colorblind-tritanopia", tritanopia_profile);
        
        // Low vision profile
        var low_vision_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.LOW_VISION);
        builtin_profiles.insert("low-vision", low_vision_profile);
        
        // Motion sensitive profile
        var motion_sensitive_profile = new AccessibilityProfile.with_type(AccessibilityProfileType.MOTION_SENSITIVE);
        builtin_profiles.insert("motion-sensitive", motion_sensitive_profile);
    }
    
    /**
     * Load user-created accessibility profiles from disk
     */
    private void load_user_profiles() {
        try {
            var dir = File.new_for_path(user_profiles_dir);
            if (!dir.query_exists()) {
                return;
            }
            
            var enumerator = dir.enumerate_children(
                FileAttribute.STANDARD_NAME,
                FileQueryInfoFlags.NONE
            );
            
            FileInfo file_info;
            while ((file_info = enumerator.next_file()) != null) {
                var filename = file_info.get_name();
                if (filename.has_suffix(".json")) {
                    load_user_profile_file(filename);
                }
            }
        } catch (Error e) {
            warning("Failed to load user accessibility profiles: %s", e.message);
        }
    }
    
    /**
     * Load a single user profile file
     */
    private void load_user_profile_file(string filename) {
        try {
            var file_path = Path.build_filename(user_profiles_dir, filename);
            string content;
            FileUtils.get_contents(file_path, out content);
            
            var profile = AccessibilityProfile.from_json(content);
            if (profile != null) {
                profile.is_user_created = true;
                user_profiles.insert(profile.name, profile);
            }
        } catch (Error e) {
            warning("Failed to load user accessibility profile %s: %s", filename, e.message);
        }
    }
    
    /**
     * Get all available accessibility profiles
     */
    public AccessibilityProfile[] get_all_profiles() {
        var profiles = new GenericArray<AccessibilityProfile>();
        
        // Add built-in profiles
        builtin_profiles.foreach((name, profile) => {
            profiles.add(profile);
        });
        
        // Add user profiles
        user_profiles.foreach((name, profile) => {
            profiles.add(profile);
        });
        
        return profiles.data;
    }
    
    /**
     * Get built-in accessibility profiles only
     */
    public AccessibilityProfile[] get_builtin_profiles() {
        var profiles = new GenericArray<AccessibilityProfile>();
        builtin_profiles.foreach((name, profile) => {
            profiles.add(profile);
        });
        return profiles.data;
    }
    
    /**
     * Get user-created accessibility profiles only
     */
    public AccessibilityProfile[] get_user_profiles() {
        var profiles = new GenericArray<AccessibilityProfile>();
        user_profiles.foreach((name, profile) => {
            profiles.add(profile);
        });
        return profiles.data;
    }
    
    /**
     * Get a specific accessibility profile by name
     */
    public AccessibilityProfile? get_profile(string name) {
        var profile = builtin_profiles.lookup(name);
        if (profile != null) {
            return profile;
        }
        
        return user_profiles.lookup(name);
    }
    
    /**
     * Get the currently active accessibility profile
     */
    public AccessibilityProfile? get_current_profile() {
        return current_profile;
    }
    
    /**
     * Set the current accessibility profile
     */
    public bool set_current_profile(string profile_name) {
        var new_profile = get_profile(profile_name);
        if (new_profile == null) {
            warning("Accessibility profile '%s' not found", profile_name);
            return false;
        }
        
        var old_profile = current_profile;
        current_profile = new_profile;
        
        profile_changed(old_profile, new_profile);
        return true;
    }
    
    /**
     * Save a user-created accessibility profile
     */
    public bool save_user_profile(AccessibilityProfile profile) throws Error {
        // Validate the profile first
        var validation = profile.validate();
        if (!validation.is_valid) {
            throw new IOError.INVALID_DATA(
                "Cannot save invalid accessibility profile: %s".printf(validation.get_summary())
            );
        }
        
        // Ensure user profiles directory exists
        var dir = File.new_for_path(user_profiles_dir);
        if (!dir.query_exists()) {
            dir.make_directory_with_parents();
        }
        
        // Mark as user-created and update timestamps
        profile.is_user_created = true;
        profile.last_modified = new DateTime.now_local();
        
        // Save to file
        var filename = "%s.json".printf(profile.name.replace(" ", "_"));
        var file_path = Path.build_filename(user_profiles_dir, filename);
        
        try {
            FileUtils.set_contents(file_path, profile.to_json());
            user_profiles.insert(profile.name, profile);
            
            profile_created(profile);
            return true;
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to save accessibility profile: %s".printf(e.message));
        }
    }
    
    /**
     * Delete a user-created accessibility profile
     */
    public bool delete_user_profile(string name) throws Error {
        var profile = user_profiles.lookup(name);
        if (profile == null) {
            throw new IOError.NOT_FOUND("User accessibility profile '%s' not found".printf(name));
        }
        
        var filename = "%s.json".printf(name.replace(" ", "_"));
        var file_path = Path.build_filename(user_profiles_dir, filename);
        
        try {
            var file = File.new_for_path(file_path);
            file.delete();
            user_profiles.remove(name);
            
            // If this was the current profile, reset to default
            if (current_profile != null && current_profile.name == name) {
                set_current_profile("none");
            }
            
            profile_deleted(name);
            return true;
        } catch (Error e) {
            throw new IOError.FAILED("Failed to delete accessibility profile: %s".printf(e.message));
        }
    }
    
    /**
     * Generate a colorblind-friendly color scheme for the specified type
     */
    public ColorScheme get_colorblind_friendly_scheme(AccessibilityProfileType colorblind_type) {
        var profile = get_profile_for_type(colorblind_type);
        if (profile != null) {
            return profile.generate_color_scheme();
        }
        
        // Fallback to creating a new profile
        var fallback_profile = new AccessibilityProfile.with_type(colorblind_type);
        return fallback_profile.generate_color_scheme();
    }
    
    /**
     * Get accessibility profile for a specific type
     */
    private AccessibilityProfile? get_profile_for_type(AccessibilityProfileType type) {
        switch (type) {
            case AccessibilityProfileType.HIGH_CONTRAST:
                return get_profile("high-contrast");
            case AccessibilityProfileType.COLORBLIND_DEUTERANOPIA:
                return get_profile("colorblind-deuteranopia");
            case AccessibilityProfileType.COLORBLIND_PROTANOPIA:
                return get_profile("colorblind-protanopia");
            case AccessibilityProfileType.COLORBLIND_TRITANOPIA:
                return get_profile("colorblind-tritanopia");
            case AccessibilityProfileType.LOW_VISION:
                return get_profile("low-vision");
            case AccessibilityProfileType.MOTION_SENSITIVE:
                return get_profile("motion-sensitive");
            default:
                return get_profile("none");
        }
    }
    
    /**
     * Apply motion reduction settings based on current profile
     */
    public void apply_motion_reduction_settings(bool reduce_motion) {
        if (current_profile == null) {
            return;
        }
        
        // Update current profile settings
        current_profile.reduce_animations = reduce_motion;
        current_profile.motion_sensitivity = reduce_motion ? 
            MotionSensitivity.REDUCED : MotionSensitivity.NONE;
        
        // If this is a user profile, save the changes
        if (current_profile.is_user_created) {
            try {
                save_user_profile(current_profile);
            } catch (Error e) {
                warning("Failed to save motion reduction settings: %s", e.message);
            }
        }
    }
    
    /**
     * Apply high contrast settings based on current profile
     */
    public void apply_high_contrast_settings(bool high_contrast) {
        if (current_profile == null) {
            return;
        }
        
        // Update current profile settings
        current_profile.high_contrast_enabled = high_contrast;
        current_profile.contrast_level = high_contrast ? 
            ContrastLevel.HIGH : ContrastLevel.NORMAL;
        
        // If this is a user profile, save the changes
        if (current_profile.is_user_created) {
            try {
                save_user_profile(current_profile);
            } catch (Error e) {
                warning("Failed to save high contrast settings: %s", e.message);
            }
        }
    }
    
    /**
     * Create a custom accessibility profile based on user preferences
     */
    public AccessibilityProfile create_custom_profile(string name, string display_name) {
        var profile = new AccessibilityProfile();
        profile.name = name;
        profile.display_name = display_name;
        profile.description = _("Custom accessibility profile");
        profile.profile_type = AccessibilityProfileType.CUSTOM;
        profile.is_user_created = true;
        
        return profile;
    }
    
    /**
     * Export an accessibility profile to a file
     */
    public bool export_profile(AccessibilityProfile profile, string file_path) throws Error {
        try {
            FileUtils.set_contents(file_path, profile.to_json());
            return true;
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to export accessibility profile: %s".printf(e.message));
        }
    }
    
    /**
     * Import an accessibility profile from a file
     */
    public AccessibilityProfile? import_profile(string file_path) throws Error {
        try {
            string content;
            FileUtils.get_contents(file_path, out content);
            
            var profile = AccessibilityProfile.from_json(content);
            if (profile != null) {
                // Validate before importing
                var validation = profile.validate();
                if (!validation.is_valid) {
                    throw new IOError.INVALID_DATA(
                        "Invalid accessibility profile: %s".printf(validation.get_summary())
                    );
                }
                
                // Check for name conflicts
                var existing = get_profile(profile.name);
                if (existing != null) {
                    profile.name = "%s (imported)".printf(profile.name);
                    profile.display_name = "%s (imported)".printf(profile.display_name);
                }
                
                return profile;
            }
            
            throw new IOError.INVALID_DATA("Failed to parse accessibility profile file");
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to import accessibility profile: %s".printf(e.message));
        }
    }
    
    /**
     * Get accessibility recommendations based on system settings
     */
    public AccessibilityProfile[] get_recommended_profiles() {
        var recommendations = new GenericArray<AccessibilityProfile>();
        
        // Check system settings for accessibility preferences
        var settings = new Settings("org.gnome.desktop.interface");
        
        // Check for high contrast preference
        if (settings.get_boolean("high-contrast")) {
            var high_contrast = get_profile("high-contrast");
            if (high_contrast != null) {
                recommendations.add(high_contrast);
            }
        }
        
        // Check for reduced motion preference
        var a11y_settings = new Settings("org.gnome.desktop.a11y");
        if (a11y_settings.get_boolean("always-show-text-caret")) {
            var motion_sensitive = get_profile("motion-sensitive");
            if (motion_sensitive != null) {
                recommendations.add(motion_sensitive);
            }
        }
        
        // Always include the standard profile as a baseline
        var none_profile = get_profile("none");
        if (none_profile != null) {
            recommendations.add(none_profile);
        }
        
        return recommendations.data;
    }
    
    /**
     * Validate accessibility compliance for a color scheme using current profile
     */
    public ValidationResult validate_scheme_accessibility(ColorScheme scheme) {
        var result = scheme.validate();
        
        if (current_profile == null) {
            return result;
        }
        
        // Apply profile-specific validation
        if (current_profile.high_contrast_enabled) {
            // Check WCAG compliance based on contrast level
            var constants = get_game_constants();
            double required_ratio = 3.0; // Default
            
            switch (current_profile.contrast_level) {
                case ContrastLevel.HIGH:
                    required_ratio = constants.WCAG_AA_RATIO;
                    break;
                case ContrastLevel.MAXIMUM:
                    required_ratio = constants.WCAG_AAA_RATIO;
                    break;
            }
            
            foreach (var color in scheme.piece_colors) {
                var contrast_ratio = calculate_contrast_ratio(color, scheme.border_color);
                if (contrast_ratio < required_ratio) {
                    result.add_warning(
                        "Color %s may not meet required contrast ratio (%.1f:1)".printf(
                            color, required_ratio
                        )
                    );
                }
            }
        }
        
        if (current_profile.colorblind_friendly) {
            // Check color distinctiveness for the specific colorblind type
            if (!check_colorblind_distinctiveness(scheme, current_profile.colorblind_type)) {
                result.add_warning(
                    "Colors may be difficult to distinguish for %s users".printf(
                        current_profile.colorblind_type
                    )
                );
            }
        }
        
        return result;
    }
    
    /**
     * Check if colors are distinct enough for specific colorblind type
     */
    private bool check_colorblind_distinctiveness(ColorScheme scheme, string colorblind_type) {
        // This is a simplified check - a real implementation would use
        // colorblind simulation algorithms specific to each type
        var constants = get_game_constants();
        double threshold = constants.COLORBLIND_THRESHOLD_BASE;
        
        switch (colorblind_type) {
            case "deuteranopia":
            case "protanopia":
                threshold = constants.COLORBLIND_THRESHOLD_RG;
                break;
            case "tritanopia":
                threshold = 60.0; // Moderate threshold for blue-yellow colorblindness
                break;
        }
        
        for (int i = 0; i < scheme.piece_colors.length; i++) {
            for (int j = i + 1; j < scheme.piece_colors.length; j++) {
                var distance = calculate_perceptual_distance(
                    scheme.piece_colors[i],
                    scheme.piece_colors[j]
                );
                if (distance < threshold) {
                    return false;
                }
            }
        }
        return true;
    }
    
    /**
     * Calculate perceptual distance between colors
     */
    private double calculate_perceptual_distance(string color1, string color2) {
        var rgb1 = hex_to_rgb(color1);
        var rgb2 = hex_to_rgb(color2);
        
        var dr = rgb1.red - rgb2.red;
        var dg = rgb1.green - rgb2.green;
        var db = rgb1.blue - rgb2.blue;
        
        return Math.sqrt(dr * dr + dg * dg + db * db);
    }
    
    /**
     * Calculate contrast ratio between two colors
     */
    private double calculate_contrast_ratio(string color1, string color2) {
        var lum1 = calculate_relative_luminance(color1);
        var lum2 = calculate_relative_luminance(color2);
        
        var lighter = Math.fmax(lum1, lum2);
        var darker = Math.fmin(lum1, lum2);
        
        return (lighter + 0.05) / (darker + 0.05);
    }
    
    /**
     * Calculate relative luminance of a color
     */
    private double calculate_relative_luminance(string color) {
        var rgb = hex_to_rgb(color);
        
        var r = rgb.red / 255.0;
        var g = rgb.green / 255.0;
        var b = rgb.blue / 255.0;
        
        r = (r <= 0.03928) ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
        g = (g <= 0.03928) ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
        b = (b <= 0.03928) ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
    
    /**
     * Convert hex color to RGB
     */
    private RGBColor hex_to_rgb(string hex_color) {
        var hex = hex_color.strip();
        if (hex.has_prefix("#")) {
            hex = hex.substring(1);
        }
        
        if (hex.length == 3) {
            hex = "%c%c%c%c%c%c".printf(
                hex[0], hex[0], hex[1], hex[1], hex[2], hex[2]
            );
        }
        
        if (hex.length != 6) {
            return RGBColor() { red = 0, green = 0, blue = 0 };
        }
        
        var red = (int) long.parse(hex.substring(0, 2), 16);
        var green = (int) long.parse(hex.substring(2, 2), 16);
        var blue = (int) long.parse(hex.substring(4, 2), 16);
        
        return RGBColor() { red = red, green = green, blue = blue };
    }
}