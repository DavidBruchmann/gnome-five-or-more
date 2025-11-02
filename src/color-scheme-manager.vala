/*
 * Five or More - Color Scheme Manager
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

// Note: AccessibilityProfile enum moved to accessibility-profile.vala
// This maintains backward compatibility while using the new system

/**
 * Manages color schemes including built-in and user-created schemes
 */
public class ColorSchemeManager : Object {
    private static ColorSchemeManager? instance = null;
    private HashTable<string, ColorScheme> builtin_schemes;
    private HashTable<string, ColorScheme> user_schemes;
    private string user_schemes_dir;
    
    construct {
        builtin_schemes = new HashTable<string, ColorScheme>(str_hash, str_equal);
        user_schemes = new HashTable<string, ColorScheme>(str_hash, str_equal);
        
        // Set up user schemes directory
        user_schemes_dir = Path.build_filename(
            Environment.get_user_config_dir(),
            "five-or-more",
            "color-schemes"
        );
        
        initialize_builtin_schemes();
        load_user_schemes();
    }
    
    /**
     * Get singleton instance
     */
    public static ColorSchemeManager get_instance() {
        if (instance == null) {
            instance = new ColorSchemeManager();
        }
        return instance;
    }
    
    /**
     * Initialize built-in color schemes
     */
    private void initialize_builtin_schemes() {
        // Classic balls theme
        var balls_scheme = new ColorScheme.with_colors("balls", {
            "#FFFF00", // Yellow
            "#FF00FF", // Magenta
            "#00FF00", // Green
            "#FF0000", // Red
            "#0000FF", // Blue
            "#00FFFF", // Cyan
            "#FF8000"  // Orange
        });
        balls_scheme.border_color = "#000000";
        balls_scheme.border_width = 5;
        builtin_schemes.insert("balls", balls_scheme);
        
        // Pastel theme
        var pastel_scheme = new ColorScheme.with_colors("pastel", {
            "#FFE4B5", // Moccasin
            "#DDA0DD", // Plum
            "#98FB98", // Pale Green
            "#F0A0A0", // Light Coral
            "#87CEEB", // Sky Blue
            "#F0E68C", // Khaki
            "#DEB887"  // Burlywood
        });
        pastel_scheme.border_color = "#696969";
        pastel_scheme.border_width = 3;
        builtin_schemes.insert("pastel", pastel_scheme);
        
        // High contrast theme
        var contrast_scheme = new ColorScheme.with_colors("high-contrast", {
            "#FFFF00", // Bright Yellow
            "#FF00FF", // Bright Magenta
            "#00FF00", // Bright Green
            "#FF0000", // Bright Red
            "#0080FF", // Bright Blue
            "#00FFFF", // Bright Cyan
            "#FF8000"  // Bright Orange
        });
        contrast_scheme.border_color = "#000000";
        contrast_scheme.border_width = 8;
        contrast_scheme.high_contrast = true;
        builtin_schemes.insert("high-contrast", contrast_scheme);
        
        // Dark theme
        var dark_scheme = new ColorScheme.with_colors("dark", {
            "#B8860B", // Dark Goldenrod
            "#8B008B", // Dark Magenta
            "#006400", // Dark Green
            "#8B0000", // Dark Red
            "#00008B", // Dark Blue
            "#008B8B", // Dark Cyan
            "#FF4500"  // Orange Red
        });
        dark_scheme.border_color = "#FFFFFF";
        dark_scheme.border_width = 4;
        builtin_schemes.insert("dark", dark_scheme);
        
        // Initialize accessibility schemes
        initialize_accessibility_schemes();
    }
    
    /**
     * Initialize accessibility-focused color schemes
     */
    private void initialize_accessibility_schemes() {
        // Deuteranopia (red-green colorblind) friendly
        var deuteranopia_scheme = new ColorScheme.with_colors("colorblind-deuteranopia", {
            "#FFD700", // Gold
            "#8A2BE2", // Blue Violet
            "#00CED1", // Dark Turquoise
            "#FF1493", // Deep Pink
            "#4169E1", // Royal Blue
            "#FF8C00", // Dark Orange
            "#9932CC"  // Dark Orchid
        });
        deuteranopia_scheme.colorblind_friendly = true;
        deuteranopia_scheme.accessibility_profile = "deuteranopia";
        deuteranopia_scheme.border_color = "#000000";
        deuteranopia_scheme.border_width = 6;
        builtin_schemes.insert("colorblind-deuteranopia", deuteranopia_scheme);
        
        // Protanopia (red-blind) friendly
        var protanopia_scheme = new ColorScheme.with_colors("colorblind-protanopia", {
            "#FFD700", // Gold
            "#4169E1", // Royal Blue
            "#00CED1", // Dark Turquoise
            "#8A2BE2", // Blue Violet
            "#FF8C00", // Dark Orange
            "#9932CC", // Dark Orchid
            "#00FA9A"  // Medium Spring Green
        });
        protanopia_scheme.colorblind_friendly = true;
        protanopia_scheme.accessibility_profile = "protanopia";
        protanopia_scheme.border_color = "#000000";
        protanopia_scheme.border_width = 6;
        builtin_schemes.insert("colorblind-protanopia", protanopia_scheme);
        
        // Tritanopia (blue-yellow colorblind) friendly
        var tritanopia_scheme = new ColorScheme.with_colors("colorblind-tritanopia", {
            "#FF1493", // Deep Pink
            "#8B0000", // Dark Red
            "#FF4500", // Orange Red
            "#DC143C", // Crimson
            "#B22222", // Fire Brick
            "#CD5C5C", // Indian Red
            "#F08080"  // Light Coral
        });
        tritanopia_scheme.colorblind_friendly = true;
        tritanopia_scheme.accessibility_profile = "tritanopia";
        tritanopia_scheme.border_color = "#000000";
        tritanopia_scheme.border_width = 6;
        builtin_schemes.insert("colorblind-tritanopia", tritanopia_scheme);
        
        // Low vision high contrast
        var low_vision_scheme = new ColorScheme.with_colors("low-vision", {
            "#FFFF00", // Bright Yellow
            "#FFFFFF", // White
            "#FF0000", // Bright Red
            "#00FF00", // Bright Green
            "#0000FF", // Bright Blue
            "#FF00FF", // Bright Magenta
            "#00FFFF"  // Bright Cyan
        });
        low_vision_scheme.high_contrast = true;
        low_vision_scheme.accessibility_profile = "low_vision";
        low_vision_scheme.border_color = "#000000";
        low_vision_scheme.border_width = 10;
        builtin_schemes.insert("low-vision", low_vision_scheme);
    }
    
    /**
     * Load user-created color schemes from disk
     */
    private void load_user_schemes() {
        try {
            var dir = File.new_for_path(user_schemes_dir);
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
                    load_user_scheme_file(filename);
                }
            }
        } catch (Error e) {
            warning("Failed to load user schemes: %s", e.message);
        }
    }
    
    /**
     * Load a single user scheme file
     */
    private void load_user_scheme_file(string filename) {
        try {
            var file_path = Path.build_filename(user_schemes_dir, filename);
            string content;
            FileUtils.get_contents(file_path, out content);
            
            var scheme = ColorScheme.from_json(content);
            if (scheme != null) {
                scheme.is_user_created = true;
                user_schemes.insert(scheme.name, scheme);
            }
        } catch (Error e) {
            warning("Failed to load user scheme %s: %s", filename, e.message);
        }
    }
    
    /**
     * Get all available color schemes
     */
    public ColorScheme[] get_all_schemes() {
        var schemes = new GenericArray<ColorScheme>();
        
        // Add built-in schemes
        builtin_schemes.foreach((name, scheme) => {
            schemes.add(scheme);
        });
        
        // Add user schemes
        user_schemes.foreach((name, scheme) => {
            schemes.add(scheme);
        });
        
        return schemes.data;
    }
    
    /**
     * Get built-in color schemes only
     */
    public ColorScheme[] get_builtin_schemes() {
        var schemes = new GenericArray<ColorScheme>();
        builtin_schemes.foreach((name, scheme) => {
            schemes.add(scheme);
        });
        return schemes.data;
    }
    
    /**
     * Get user-created color schemes only
     */
    public ColorScheme[] get_user_schemes() {
        var schemes = new GenericArray<ColorScheme>();
        user_schemes.foreach((name, scheme) => {
            schemes.add(scheme);
        });
        return schemes.data;
    }
    
    /**
     * Get a specific color scheme by name
     */
    public ColorScheme? get_scheme(string name) {
        var scheme = builtin_schemes.lookup(name);
        if (scheme != null) {
            return scheme;
        }
        
        return user_schemes.lookup(name);
    }
    
    /**
     * Save a user-created color scheme
     */
    public bool save_user_scheme(ColorScheme scheme) throws Error {
        // Validate the scheme first
        var validation = scheme.validate();
        if (!validation.is_valid) {
            throw new IOError.INVALID_DATA(
                "Cannot save invalid color scheme: %s".printf(validation.get_summary())
            );
        }
        
        // Ensure user schemes directory exists
        var dir = File.new_for_path(user_schemes_dir);
        if (!dir.query_exists()) {
            dir.make_directory_with_parents();
        }
        
        // Mark as user-created
        scheme.is_user_created = true;
        scheme.created_date = new DateTime.now_local();
        
        // Save to file
        var filename = "%s.json".printf(scheme.name.replace(" ", "_"));
        var file_path = Path.build_filename(user_schemes_dir, filename);
        
        try {
            FileUtils.set_contents(file_path, scheme.to_json());
            user_schemes.insert(scheme.name, scheme);
            return true;
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to save color scheme: %s".printf(e.message));
        }
    }
    
    /**
     * Delete a user-created color scheme
     */
    public bool delete_user_scheme(string name) throws Error {
        var scheme = user_schemes.lookup(name);
        if (scheme == null) {
            throw new IOError.NOT_FOUND("User scheme '%s' not found".printf(name));
        }
        
        var filename = "%s.json".printf(name.replace(" ", "_"));
        var file_path = Path.build_filename(user_schemes_dir, filename);
        
        try {
            var file = File.new_for_path(file_path);
            file.delete();
            user_schemes.remove(name);
            return true;
        } catch (Error e) {
            throw new IOError.FAILED("Failed to delete color scheme: %s".printf(e.message));
        }
    }
    
    /**
     * Create an accessibility-optimized color scheme using AccessibilityManager
     */
    public ColorScheme create_accessibility_scheme(AccessibilityProfileType profile_type) {
        var accessibility_manager = AccessibilityManager.get_instance();
        return accessibility_manager.get_colorblind_friendly_scheme(profile_type);
    }
    
    /**
     * Legacy method for backward compatibility
     */
    public ColorScheme create_accessibility_scheme_legacy(string profile_name) {
        switch (profile_name.down()) {
            case "high_contrast":
                return get_scheme("high-contrast") ?? create_high_contrast_scheme();
            case "colorblind_deuteranopia":
                return get_scheme("colorblind-deuteranopia") ?? create_deuteranopia_scheme();
            case "colorblind_protanopia":
                return get_scheme("colorblind-protanopia") ?? create_protanopia_scheme();
            case "colorblind_tritanopia":
                return get_scheme("colorblind-tritanopia") ?? create_tritanopia_scheme();
            case "low_vision":
                return get_scheme("low-vision") ?? create_low_vision_scheme();
            default:
                return get_scheme("balls") ?? create_default_scheme();
        }
    }
    
    /**
     * Create a high contrast color scheme
     */
    private ColorScheme create_high_contrast_scheme() {
        var scheme = new ColorScheme.with_colors("generated-high-contrast", {
            "#FFFF00", "#FF00FF", "#00FF00", "#FF0000",
            "#0080FF", "#00FFFF", "#FF8000"
        });
        scheme.border_color = "#000000";
        scheme.border_width = 8;
        scheme.high_contrast = true;
        return scheme;
    }
    
    /**
     * Create a deuteranopia-friendly color scheme
     */
    private ColorScheme create_deuteranopia_scheme() {
        var scheme = new ColorScheme.with_colors("generated-deuteranopia", {
            "#FFD700", "#8A2BE2", "#00CED1", "#FF1493",
            "#4169E1", "#FF8C00", "#9932CC"
        });
        scheme.colorblind_friendly = true;
        scheme.accessibility_profile = "deuteranopia";
        return scheme;
    }
    
    /**
     * Create a protanopia-friendly color scheme
     */
    private ColorScheme create_protanopia_scheme() {
        var scheme = new ColorScheme.with_colors("generated-protanopia", {
            "#FFD700", "#4169E1", "#00CED1", "#8A2BE2",
            "#FF8C00", "#9932CC", "#00FA9A"
        });
        scheme.colorblind_friendly = true;
        scheme.accessibility_profile = "protanopia";
        return scheme;
    }
    
    /**
     * Create a tritanopia-friendly color scheme
     */
    private ColorScheme create_tritanopia_scheme() {
        var scheme = new ColorScheme.with_colors("generated-tritanopia", {
            "#FF1493", "#8B0000", "#FF4500", "#DC143C",
            "#B22222", "#CD5C5C", "#F08080"
        });
        scheme.colorblind_friendly = true;
        scheme.accessibility_profile = "tritanopia";
        return scheme;
    }
    
    /**
     * Create a low vision optimized color scheme
     */
    private ColorScheme create_low_vision_scheme() {
        var scheme = new ColorScheme.with_colors("generated-low-vision", {
            "#FFFF00", "#FFFFFF", "#FF0000", "#00FF00",
            "#0000FF", "#FF00FF", "#00FFFF"
        });
        scheme.border_color = "#000000";
        scheme.border_width = 10;
        scheme.high_contrast = true;
        scheme.accessibility_profile = "low_vision";
        return scheme;
    }
    
    /**
     * Create a default fallback color scheme
     */
    private ColorScheme create_default_scheme() {
        return new ColorScheme.with_colors("default", {
            "#FFFF00", "#FF00FF", "#00FF00", "#FF0000",
            "#0000FF", "#00FFFF", "#FF8000"
        });
    }
    
    /**
     * Export a color scheme to a file
     */
    public bool export_scheme(ColorScheme scheme, string file_path) throws Error {
        try {
            FileUtils.set_contents(file_path, scheme.to_json());
            return true;
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to export color scheme: %s".printf(e.message));
        }
    }
    
    /**
     * Import a color scheme from a file
     */
    public ColorScheme? import_scheme(string file_path) throws Error {
        try {
            string content;
            FileUtils.get_contents(file_path, out content);
            
            var scheme = ColorScheme.from_json(content);
            if (scheme != null) {
                // Validate before importing
                var validation = scheme.validate();
                if (!validation.is_valid) {
                    throw new IOError.INVALID_DATA(
                        "Invalid color scheme: %s".printf(validation.get_summary())
                    );
                }
                
                // Check for name conflicts
                var existing = get_scheme(scheme.name);
                if (existing != null) {
                    scheme.name = "%s (imported)".printf(scheme.name);
                }
                
                return scheme;
            }
            
            throw new IOError.INVALID_DATA("Failed to parse color scheme file");
        } catch (FileError e) {
            throw new IOError.FAILED("Failed to import color scheme: %s".printf(e.message));
        }
    }
    
    /**
     * Validate and check accessibility compliance for a color scheme
     */
    public ValidationResult validate_scheme_accessibility(ColorScheme scheme) {
        var result = scheme.validate();
        
        // Additional accessibility checks
        if (scheme.high_contrast) {
            // Check WCAG AA compliance (4.5:1 contrast ratio)
            foreach (var color in scheme.piece_colors) {
                var contrast_ratio = calculate_contrast_ratio(color, scheme.border_color);
                if (contrast_ratio < 4.5) {
                    result.add_warning(
                        "Color %s may not meet WCAG AA contrast requirements".printf(color)
                    );
                }
            }
        }
        
        if (scheme.colorblind_friendly) {
            // Check color distinctiveness for colorblind users
            if (!check_colorblind_distinctiveness(scheme)) {
                result.add_warning("Colors may be difficult to distinguish for colorblind users");
            }
        }
        
        return result;
    }
    
    /**
     * Check if colors are distinct enough for colorblind users
     */
    private bool check_colorblind_distinctiveness(ColorScheme scheme) {
        // This is a simplified check - a real implementation would use
        // colorblind simulation algorithms
        for (int i = 0; i < scheme.piece_colors.length; i++) {
            for (int j = i + 1; j < scheme.piece_colors.length; j++) {
                var distance = calculate_perceptual_distance(
                    scheme.piece_colors[i],
                    scheme.piece_colors[j]
                );
                if (distance < 75.0) { // Threshold for colorblind distinctiveness
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
        // Simplified implementation - would use LAB color space in production
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