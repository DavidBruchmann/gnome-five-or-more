/*
 * Five or More - Accessibility Profile System
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
 * Accessibility profile types for users with specific accessibility needs
 */
public enum AccessibilityProfileType {
    NONE,
    HIGH_CONTRAST,
    COLORBLIND_DEUTERANOPIA,
    COLORBLIND_PROTANOPIA,
    COLORBLIND_TRITANOPIA,
    LOW_VISION,
    MOTION_SENSITIVE,
    CUSTOM
}

/**
 * Visual sensitivity levels for motion and animation
 */
public enum MotionSensitivity {
    NONE,           // Full animations
    REDUCED,        // Reduced motion effects
    MINIMAL,        // Essential animations only
    DISABLED        // No animations
}

/**
 * Contrast sensitivity levels
 */
public enum ContrastLevel {
    NORMAL,         // Standard contrast
    ENHANCED,       // Slightly enhanced contrast
    HIGH,           // High contrast (WCAG AA)
    MAXIMUM         // Maximum contrast (WCAG AAA)
}

/**
 * Comprehensive accessibility profile configuration
 */
public class AccessibilityProfile : Object {
    public string name { get; set; }
    public string display_name { get; set; }
    public string description { get; set; }
    public AccessibilityProfileType profile_type { get; set; }
    
    // Visual accessibility settings
    public ContrastLevel contrast_level { get; set; default = ContrastLevel.NORMAL; }
    public bool high_contrast_enabled { get; set; default = false; }
    public bool colorblind_friendly { get; set; default = false; }
    public string colorblind_type { get; set; default = "none"; }
    
    // Motion and animation settings
    public MotionSensitivity motion_sensitivity { get; set; default = MotionSensitivity.NONE; }
    public bool reduce_animations { get; set; default = false; }
    public bool disable_transitions { get; set; default = false; }
    public double animation_speed_multiplier { get; set; default = 1.0; }
    
    // Visual enhancement settings
    public int border_width_multiplier { get; set; default = 1; }
    public double opacity_adjustment { get; set; default = 0.0; }
    public bool enhanced_focus_indicators { get; set; default = false; }
    public bool large_ui_elements { get; set; default = false; }
    
    // Color customization
    public string[] preferred_colors { get; set; }
    public string background_color { get; set; default = "#FFFFFF"; }
    public string border_color { get; set; default = "#000000"; }
    
    // User preferences
    public bool is_user_created { get; set; default = false; }
    public DateTime created_date { get; set; }
    public DateTime last_modified { get; set; }
    
    construct {
        created_date = new DateTime.now_local();
        last_modified = new DateTime.now_local();
    }
    
    /**
     * Create accessibility profile with specified type
     */
    public AccessibilityProfile.with_type(AccessibilityProfileType type) {
        this.profile_type = type;
        this.name = get_profile_name_for_type(type);
        this.display_name = get_display_name_for_type(type);
        this.description = get_description_for_type(type);
        
        configure_for_type(type);
    }
    
    /**
     * Get profile name for a given type
     */
    private string get_profile_name_for_type(AccessibilityProfileType type) {
        switch (type) {
            case AccessibilityProfileType.HIGH_CONTRAST:
                return "high-contrast";
            case AccessibilityProfileType.COLORBLIND_DEUTERANOPIA:
                return "colorblind-deuteranopia";
            case AccessibilityProfileType.COLORBLIND_PROTANOPIA:
                return "colorblind-protanopia";
            case AccessibilityProfileType.COLORBLIND_TRITANOPIA:
                return "colorblind-tritanopia";
            case AccessibilityProfileType.LOW_VISION:
                return "low-vision";
            case AccessibilityProfileType.MOTION_SENSITIVE:
                return "motion-sensitive";
            case AccessibilityProfileType.CUSTOM:
                return "custom";
            default:
                return "none";
        }
    }
    
    /**
     * Get display name for a given type
     */
    private string get_display_name_for_type(AccessibilityProfileType type) {
        switch (type) {
            case AccessibilityProfileType.HIGH_CONTRAST:
                return _("High Contrast");
            case AccessibilityProfileType.COLORBLIND_DEUTERANOPIA:
                return _("Colorblind (Deuteranopia)");
            case AccessibilityProfileType.COLORBLIND_PROTANOPIA:
                return _("Colorblind (Protanopia)");
            case AccessibilityProfileType.COLORBLIND_TRITANOPIA:
                return _("Colorblind (Tritanopia)");
            case AccessibilityProfileType.LOW_VISION:
                return _("Low Vision");
            case AccessibilityProfileType.MOTION_SENSITIVE:
                return _("Motion Sensitive");
            case AccessibilityProfileType.CUSTOM:
                return _("Custom Profile");
            default:
                return _("Standard");
        }
    }
    
    /**
     * Get description for a given type
     */
    private string get_description_for_type(AccessibilityProfileType type) {
        switch (type) {
            case AccessibilityProfileType.HIGH_CONTRAST:
                return _("Enhanced contrast for better visibility");
            case AccessibilityProfileType.COLORBLIND_DEUTERANOPIA:
                return _("Optimized colors for red-green colorblindness (deuteranopia)");
            case AccessibilityProfileType.COLORBLIND_PROTANOPIA:
                return _("Optimized colors for red-blind users (protanopia)");
            case AccessibilityProfileType.COLORBLIND_TRITANOPIA:
                return _("Optimized colors for blue-yellow colorblindness (tritanopia)");
            case AccessibilityProfileType.LOW_VISION:
                return _("Large elements and maximum contrast for low vision users");
            case AccessibilityProfileType.MOTION_SENSITIVE:
                return _("Reduced animations for motion-sensitive users");
            case AccessibilityProfileType.CUSTOM:
                return _("User-customized accessibility settings");
            default:
                return _("Standard accessibility settings");
        }
    }
    
    /**
     * Configure profile settings based on type
     */
    private void configure_for_type(AccessibilityProfileType type) {
        switch (type) {
            case AccessibilityProfileType.HIGH_CONTRAST:
                configure_high_contrast();
                break;
            case AccessibilityProfileType.COLORBLIND_DEUTERANOPIA:
                configure_deuteranopia();
                break;
            case AccessibilityProfileType.COLORBLIND_PROTANOPIA:
                configure_protanopia();
                break;
            case AccessibilityProfileType.COLORBLIND_TRITANOPIA:
                configure_tritanopia();
                break;
            case AccessibilityProfileType.LOW_VISION:
                configure_low_vision();
                break;
            case AccessibilityProfileType.MOTION_SENSITIVE:
                configure_motion_sensitive();
                break;
        }
    }
    
    /**
     * Configure high contrast settings
     */
    private void configure_high_contrast() {
        contrast_level = ContrastLevel.HIGH;
        high_contrast_enabled = true;
        border_width_multiplier = 2;
        enhanced_focus_indicators = true;
        
        preferred_colors = {
            "#FFFF00", // Bright Yellow
            "#FF00FF", // Bright Magenta
            "#00FF00", // Bright Green
            "#FF0000", // Bright Red
            "#0080FF", // Bright Blue
            "#00FFFF", // Bright Cyan
            "#FF8000"  // Bright Orange
        };
        
        background_color = "#FFFFFF";
        border_color = "#000000";
    }
    
    /**
     * Configure deuteranopia-friendly settings
     */
    private void configure_deuteranopia() {
        colorblind_friendly = true;
        colorblind_type = "deuteranopia";
        contrast_level = ContrastLevel.ENHANCED;
        border_width_multiplier = 2;
        
        // Colors that are distinguishable for deuteranopia
        preferred_colors = {
            "#FFD700", // Gold
            "#8A2BE2", // Blue Violet
            "#00CED1", // Dark Turquoise
            "#FF1493", // Deep Pink
            "#4169E1", // Royal Blue
            "#FF8C00", // Dark Orange
            "#9932CC"  // Dark Orchid
        };
        
        border_color = "#000000";
    }
    
    /**
     * Configure protanopia-friendly settings
     */
    private void configure_protanopia() {
        colorblind_friendly = true;
        colorblind_type = "protanopia";
        contrast_level = ContrastLevel.ENHANCED;
        border_width_multiplier = 2;
        
        // Colors that are distinguishable for protanopia
        preferred_colors = {
            "#FFD700", // Gold
            "#4169E1", // Royal Blue
            "#00CED1", // Dark Turquoise
            "#8A2BE2", // Blue Violet
            "#FF8C00", // Dark Orange
            "#9932CC", // Dark Orchid
            "#00FA9A"  // Medium Spring Green
        };
        
        border_color = "#000000";
    }
    
    /**
     * Configure tritanopia-friendly settings
     */
    private void configure_tritanopia() {
        colorblind_friendly = true;
        colorblind_type = "tritanopia";
        contrast_level = ContrastLevel.ENHANCED;
        border_width_multiplier = 2;
        
        // Colors that are distinguishable for tritanopia
        preferred_colors = {
            "#FF1493", // Deep Pink
            "#8B0000", // Dark Red
            "#FF4500", // Orange Red
            "#DC143C", // Crimson
            "#B22222", // Fire Brick
            "#CD5C5C", // Indian Red
            "#F08080"  // Light Coral
        };
        
        border_color = "#000000";
    }
    
    /**
     * Configure low vision settings
     */
    private void configure_low_vision() {
        contrast_level = ContrastLevel.MAXIMUM;
        high_contrast_enabled = true;
        border_width_multiplier = 3;
        enhanced_focus_indicators = true;
        large_ui_elements = true;
        
        preferred_colors = {
            "#FFFF00", // Bright Yellow
            "#FFFFFF", // White
            "#FF0000", // Bright Red
            "#00FF00", // Bright Green
            "#0000FF", // Bright Blue
            "#FF00FF", // Bright Magenta
            "#00FFFF"  // Bright Cyan
        };
        
        background_color = "#000000";
        border_color = "#FFFFFF";
    }
    
    /**
     * Configure motion sensitive settings
     */
    private void configure_motion_sensitive() {
        motion_sensitivity = MotionSensitivity.MINIMAL;
        reduce_animations = true;
        disable_transitions = true;
        animation_speed_multiplier = 0.5;
    }
    
    /**
     * Generate a color scheme based on this accessibility profile
     */
    public ColorScheme generate_color_scheme() {
        var scheme = new ColorScheme();
        scheme.name = "accessibility-%s".printf(name);
        
        // Use preferred colors if available
        if (preferred_colors != null && preferred_colors.length >= 7) {
            scheme.piece_colors = preferred_colors;
        } else {
            scheme.piece_colors = get_default_accessible_colors();
        }
        
        // Apply accessibility settings
        scheme.border_color = border_color;
        scheme.border_width = 5 * border_width_multiplier;
        scheme.high_contrast = high_contrast_enabled;
        scheme.colorblind_friendly = colorblind_friendly;
        scheme.accessibility_profile = name;
        
        // Adjust opacity if needed
        if (opacity_adjustment != 0.0) {
            scheme.opacity = (1.0 + opacity_adjustment).clamp(0.1, 1.0);
        }
        
        return scheme;
    }
    
    /**
     * Get default accessible colors
     */
    private string[] get_default_accessible_colors() {
        return {
            "#FFFF00", // Yellow
            "#FF00FF", // Magenta
            "#00FF00", // Green
            "#FF0000", // Red
            "#0000FF", // Blue
            "#00FFFF", // Cyan
            "#FF8000"  // Orange
        };
    }
    
    /**
     * Validate accessibility profile settings
     */
    public ValidationResult validate() {
        var result = new ValidationResult();
        
        // Check basic requirements
        if (name == null || name.strip() == "") {
            result.add_error("Profile name cannot be empty");
        }
        
        if (display_name == null || display_name.strip() == "") {
            result.add_error("Display name cannot be empty");
        }
        
        // Validate ranges
        if (border_width_multiplier < 1 || border_width_multiplier > 5) {
            result.add_error("Border width multiplier must be between 1 and 5");
        }
        
        if (animation_speed_multiplier < 0.1 || animation_speed_multiplier > 3.0) {
            result.add_error("Animation speed multiplier must be between 0.1 and 3.0");
        }
        
        if (opacity_adjustment < -0.5 || opacity_adjustment > 0.5) {
            result.add_error("Opacity adjustment must be between -0.5 and 0.5");
        }
        
        // Validate colors if provided
        if (preferred_colors != null) {
            if (preferred_colors.length < 7) {
                result.add_error("Must have at least 7 preferred colors");
            }
            
            foreach (var color in preferred_colors) {
                if (!is_valid_color_format(color)) {
                    result.add_error("Invalid color format: %s".printf(color));
                }
            }
        }
        
        if (!is_valid_color_format(background_color)) {
            result.add_error("Invalid background color format");
        }
        
        if (!is_valid_color_format(border_color)) {
            result.add_error("Invalid border color format");
        }
        
        // Check accessibility compliance
        if (high_contrast_enabled) {
            if (preferred_colors != null) {
                foreach (var color in preferred_colors) {
                    var contrast = calculate_contrast_ratio(color, border_color);
                    if (contrast < 4.5) {
                        result.add_warning(
                            "Color %s may not meet WCAG AA contrast requirements".printf(color)
                        );
                    }
                }
            }
        }
        
        return result;
    }
    
    /**
     * Check if a color string is in valid format
     */
    private bool is_valid_color_format(string color) {
        var trimmed = color.strip();
        
        // Check hex format
        if (trimmed.has_prefix("#")) {
            var hex_part = trimmed.substring(1);
            if (hex_part.length == 3 || hex_part.length == 6 || hex_part.length == 8) {
                return validate_hex_string(hex_part);
            }
        }
        
        // Check rgb/rgba format
        if (trimmed.has_prefix("rgb(") || trimmed.has_prefix("rgba(")) {
            return true; // Simplified validation
        }
        
        // Check hsl/hsla format
        if (trimmed.has_prefix("hsl(") || trimmed.has_prefix("hsla(")) {
            return true; // Simplified validation
        }
        
        return false;
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
    
    /**
     * Serialize accessibility profile to JSON
     */
    public string to_json() {
        var builder = new Json.Builder();
        builder.begin_object();
        
        builder.set_member_name("name");
        builder.add_string_value(name);
        
        builder.set_member_name("display_name");
        builder.add_string_value(display_name);
        
        builder.set_member_name("description");
        builder.add_string_value(description);
        
        builder.set_member_name("profile_type");
        builder.add_string_value(profile_type.to_string());
        
        builder.set_member_name("contrast_level");
        builder.add_string_value(contrast_level.to_string());
        
        builder.set_member_name("high_contrast_enabled");
        builder.add_boolean_value(high_contrast_enabled);
        
        builder.set_member_name("colorblind_friendly");
        builder.add_boolean_value(colorblind_friendly);
        
        builder.set_member_name("colorblind_type");
        builder.add_string_value(colorblind_type);
        
        builder.set_member_name("motion_sensitivity");
        builder.add_string_value(motion_sensitivity.to_string());
        
        builder.set_member_name("reduce_animations");
        builder.add_boolean_value(reduce_animations);
        
        builder.set_member_name("disable_transitions");
        builder.add_boolean_value(disable_transitions);
        
        builder.set_member_name("animation_speed_multiplier");
        builder.add_double_value(animation_speed_multiplier);
        
        builder.set_member_name("border_width_multiplier");
        builder.add_int_value(border_width_multiplier);
        
        builder.set_member_name("opacity_adjustment");
        builder.add_double_value(opacity_adjustment);
        
        builder.set_member_name("enhanced_focus_indicators");
        builder.add_boolean_value(enhanced_focus_indicators);
        
        builder.set_member_name("large_ui_elements");
        builder.add_boolean_value(large_ui_elements);
        
        if (preferred_colors != null) {
            builder.set_member_name("preferred_colors");
            builder.begin_array();
            foreach (var color in preferred_colors) {
                builder.add_string_value(color);
            }
            builder.end_array();
        }
        
        builder.set_member_name("background_color");
        builder.add_string_value(background_color);
        
        builder.set_member_name("border_color");
        builder.add_string_value(border_color);
        
        builder.set_member_name("is_user_created");
        builder.add_boolean_value(is_user_created);
        
        builder.set_member_name("created_date");
        builder.add_string_value(created_date.format_iso8601());
        
        builder.set_member_name("last_modified");
        builder.add_string_value(last_modified.format_iso8601());
        
        builder.end_object();
        
        var generator = new Json.Generator();
        generator.set_root(builder.get_root());
        return generator.to_data(null);
    }
    
    /**
     * Create accessibility profile from JSON
     */
    public static AccessibilityProfile? from_json(string json_data) throws Error {
        var parser = new Json.Parser();
        parser.load_from_data(json_data);
        
        var root = parser.get_root();
        if (root == null || root.get_node_type() != Json.NodeType.OBJECT) {
            throw new IOError.INVALID_DATA("Invalid JSON format");
        }
        
        var obj = root.get_object();
        var profile = new AccessibilityProfile();
        
        if (obj.has_member("name")) {
            profile.name = obj.get_string_member("name");
        }
        
        if (obj.has_member("display_name")) {
            profile.display_name = obj.get_string_member("display_name");
        }
        
        if (obj.has_member("description")) {
            profile.description = obj.get_string_member("description");
        }
        
        // Parse enum values with error handling
        if (obj.has_member("profile_type")) {
            var type_str = obj.get_string_member("profile_type");
            profile.profile_type = parse_profile_type(type_str);
        }
        
        if (obj.has_member("contrast_level")) {
            var level_str = obj.get_string_member("contrast_level");
            profile.contrast_level = parse_contrast_level(level_str);
        }
        
        if (obj.has_member("motion_sensitivity")) {
            var sensitivity_str = obj.get_string_member("motion_sensitivity");
            profile.motion_sensitivity = parse_motion_sensitivity(sensitivity_str);
        }
        
        // Parse boolean values
        if (obj.has_member("high_contrast_enabled")) {
            profile.high_contrast_enabled = obj.get_boolean_member("high_contrast_enabled");
        }
        
        if (obj.has_member("colorblind_friendly")) {
            profile.colorblind_friendly = obj.get_boolean_member("colorblind_friendly");
        }
        
        if (obj.has_member("colorblind_type")) {
            profile.colorblind_type = obj.get_string_member("colorblind_type");
        }
        
        if (obj.has_member("reduce_animations")) {
            profile.reduce_animations = obj.get_boolean_member("reduce_animations");
        }
        
        if (obj.has_member("disable_transitions")) {
            profile.disable_transitions = obj.get_boolean_member("disable_transitions");
        }
        
        if (obj.has_member("enhanced_focus_indicators")) {
            profile.enhanced_focus_indicators = obj.get_boolean_member("enhanced_focus_indicators");
        }
        
        if (obj.has_member("large_ui_elements")) {
            profile.large_ui_elements = obj.get_boolean_member("large_ui_elements");
        }
        
        if (obj.has_member("is_user_created")) {
            profile.is_user_created = obj.get_boolean_member("is_user_created");
        }
        
        // Parse numeric values
        if (obj.has_member("animation_speed_multiplier")) {
            profile.animation_speed_multiplier = obj.get_double_member("animation_speed_multiplier");
        }
        
        if (obj.has_member("border_width_multiplier")) {
            profile.border_width_multiplier = (int) obj.get_int_member("border_width_multiplier");
        }
        
        if (obj.has_member("opacity_adjustment")) {
            profile.opacity_adjustment = obj.get_double_member("opacity_adjustment");
        }
        
        // Parse color arrays
        if (obj.has_member("preferred_colors")) {
            var colors_array = obj.get_array_member("preferred_colors");
            var colors = new string[colors_array.get_length()];
            for (uint i = 0; i < colors_array.get_length(); i++) {
                colors[i] = colors_array.get_string_element(i);
            }
            profile.preferred_colors = colors;
        }
        
        if (obj.has_member("background_color")) {
            profile.background_color = obj.get_string_member("background_color");
        }
        
        if (obj.has_member("border_color")) {
            profile.border_color = obj.get_string_member("border_color");
        }
        
        // Parse dates
        if (obj.has_member("created_date")) {
            try {
                profile.created_date = new DateTime.from_iso8601(
                    obj.get_string_member("created_date"), null
                );
            } catch (Error e) {
                profile.created_date = new DateTime.now_local();
            }
        }
        
        if (obj.has_member("last_modified")) {
            try {
                profile.last_modified = new DateTime.from_iso8601(
                    obj.get_string_member("last_modified"), null
                );
            } catch (Error e) {
                profile.last_modified = new DateTime.now_local();
            }
        }
        
        return profile;
    }
    
    /**
     * Parse profile type from string
     */
    private static AccessibilityProfileType parse_profile_type(string type_str) {
        switch (type_str.down()) {
            case "high_contrast":
                return AccessibilityProfileType.HIGH_CONTRAST;
            case "colorblind_deuteranopia":
                return AccessibilityProfileType.COLORBLIND_DEUTERANOPIA;
            case "colorblind_protanopia":
                return AccessibilityProfileType.COLORBLIND_PROTANOPIA;
            case "colorblind_tritanopia":
                return AccessibilityProfileType.COLORBLIND_TRITANOPIA;
            case "low_vision":
                return AccessibilityProfileType.LOW_VISION;
            case "motion_sensitive":
                return AccessibilityProfileType.MOTION_SENSITIVE;
            case "custom":
                return AccessibilityProfileType.CUSTOM;
            default:
                return AccessibilityProfileType.NONE;
        }
    }
    
    /**
     * Parse contrast level from string
     */
    private static ContrastLevel parse_contrast_level(string level_str) {
        switch (level_str.down()) {
            case "enhanced":
                return ContrastLevel.ENHANCED;
            case "high":
                return ContrastLevel.HIGH;
            case "maximum":
                return ContrastLevel.MAXIMUM;
            default:
                return ContrastLevel.NORMAL;
        }
    }
    
    /**
     * Parse motion sensitivity from string
     */
    private static MotionSensitivity parse_motion_sensitivity(string sensitivity_str) {
        switch (sensitivity_str.down()) {
            case "reduced":
                return MotionSensitivity.REDUCED;
            case "minimal":
                return MotionSensitivity.MINIMAL;
            case "disabled":
                return MotionSensitivity.DISABLED;
            default:
                return MotionSensitivity.NONE;
        }
    }
}