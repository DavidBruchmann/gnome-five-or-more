/*
 * Five or More - Color Scheme Data Model
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
 * Represents a color scheme for game pieces with accessibility and validation features
 */
public class ColorScheme : Object {
    public string name { get; set; }
    public string[] piece_colors { get; set; }
    public string border_color { get; set; default = "#000000"; }
    public int border_width { get; set; default = 5; }
    public double opacity { get; set; default = 1.0; }
    public bool high_contrast { get; set; default = false; }
    public bool is_user_created { get; set; default = false; }
    public DateTime created_date { get; set; }
    
    // Accessibility properties
    public bool colorblind_friendly { get; set; default = false; }
    public string accessibility_profile { get; set; default = "none"; }
    
    construct {
        created_date = new DateTime.now_local();
        
        // Initialize with default colors if not set
        if (piece_colors == null || piece_colors.length == 0) {
            piece_colors = get_default_colors();
        }
    }
    
    /**
     * Create a color scheme with specified parameters
     */
    public ColorScheme.with_colors(string name, string[] colors) {
        this.name = name;
        this.piece_colors = colors;
    }
    
    /**
     * Get default piece colors
     */
    private string[] get_default_colors() {
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
     * Validate the color scheme for correctness and accessibility
     */
    public ValidationResult validate() {
        var result = new ValidationResult();
        
        // Check basic requirements
        if (name == null || name.strip() == "") {
            result.add_error("Color scheme name cannot be empty");
        }
        
        if (piece_colors == null || piece_colors.length < 7) {
            result.add_error("Color scheme must have at least 7 piece colors");
        }
        
        // Validate color format
        foreach (var color in piece_colors) {
            if (!is_valid_color_format(color)) {
                result.add_error("Invalid color format: %s".printf(color));
            }
        }
        
        if (!is_valid_color_format(border_color)) {
            result.add_error("Invalid border color format: %s".printf(border_color));
        }
        
        // Validate ranges
        if (border_width < 0 || border_width > 20) {
            result.add_error("Border width must be between 0 and 20");
        }
        
        if (opacity < 0.0 || opacity > 1.0) {
            result.add_error("Opacity must be between 0.0 and 1.0");
        }
        
        // Check for color distinctiveness
        if (!check_color_distinctiveness()) {
            result.add_warning("Some colors may be too similar for accessibility");
        }
        
        // Check contrast if high contrast is enabled
        if (high_contrast && !validate_high_contrast()) {
            result.add_error("High contrast mode requires sufficient contrast ratios");
        }
        
        return result;
    }
    
    /**
     * Check if a color string is in valid format (hex, rgb, hsl)
     */
    private bool is_valid_color_format(string color) {
        var trimmed = color.strip();
        
        // Check hex format (#RGB, #RRGGBB, #RRGGBBAA)
        if (trimmed.has_prefix("#")) {
            var hex_part = trimmed.substring(1);
            if (hex_part.length == 3 || hex_part.length == 6 || hex_part.length == 8) {
                return validate_hex_string(hex_part);
            }
        }
        
        // Check rgb/rgba format
        if (trimmed.has_prefix("rgb(") || trimmed.has_prefix("rgba(")) {
            return validate_rgb_format(trimmed);
        }
        
        // Check hsl/hsla format
        if (trimmed.has_prefix("hsl(") || trimmed.has_prefix("hsla(")) {
            return validate_hsl_format(trimmed);
        }
        
        return false;
    }
    
    /**
     * Validate RGB color format
     */
    private bool validate_rgb_format(string color) {
        // Simple validation - in a real implementation, this would be more thorough
        return color.contains(",") && color.has_suffix(")");
    }
    
    /**
     * Validate HSL color format
     */
    private bool validate_hsl_format(string color) {
        // Simple validation - in a real implementation, this would be more thorough
        return color.contains(",") && color.has_suffix(")");
    }
    
    /**
     * Check if colors are sufficiently distinct for accessibility
     */
    private bool check_color_distinctiveness() {
        for (int i = 0; i < piece_colors.length; i++) {
            for (int j = i + 1; j < piece_colors.length; j++) {
                if (calculate_color_distance(piece_colors[i], piece_colors[j]) < 50.0) {
                    return false;
                }
            }
        }
        return true;
    }
    
    /**
     * Calculate perceptual distance between two colors
     */
    private double calculate_color_distance(string color1, string color2) {
        var rgb1 = hex_to_rgb(color1);
        var rgb2 = hex_to_rgb(color2);
        
        // Simple Euclidean distance in RGB space
        // In a real implementation, this would use LAB color space for better perceptual accuracy
        var dr = rgb1.red - rgb2.red;
        var dg = rgb1.green - rgb2.green;
        var db = rgb1.blue - rgb2.blue;
        
        return Math.sqrt(dr * dr + dg * dg + db * db);
    }
    
    /**
     * Validate high contrast requirements
     */
    private bool validate_high_contrast() {
        // Check contrast ratio between pieces and border
        foreach (var color in piece_colors) {
            if (calculate_contrast_ratio(color, border_color) < 4.5) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Calculate WCAG contrast ratio between two colors
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
        
        // Convert to linear RGB
        var r = rgb.red / 255.0;
        var g = rgb.green / 255.0;
        var b = rgb.blue / 255.0;
        
        r = (r <= 0.03928) ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
        g = (g <= 0.03928) ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
        b = (b <= 0.03928) ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
    
    /**
     * Convert hex color to RGB values
     */
    private RGBColor hex_to_rgb(string hex_color) {
        var hex = hex_color.strip();
        if (hex.has_prefix("#")) {
            hex = hex.substring(1);
        }
        
        // Handle 3-digit hex
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
     * Convert RGB to hex color
     */
    public static string rgb_to_hex(int red, int green, int blue) {
        return "#%02X%02X%02X".printf(
            red.clamp(0, 255),
            green.clamp(0, 255),
            blue.clamp(0, 255)
        );
    }
    
    /**
     * Convert HSL to RGB
     */
    public static RGBColor hsl_to_rgb(double hue, double saturation, double lightness) {
        hue = hue % 360.0;
        saturation = saturation.clamp(0.0, 1.0);
        lightness = lightness.clamp(0.0, 1.0);
        
        var c = (1.0 - Math.fabs(2.0 * lightness - 1.0)) * saturation;
        var x = c * (1.0 - Math.fabs((hue / 60.0) % 2.0 - 1.0));
        var m = lightness - c / 2.0;
        
        double r, g, b;
        
        if (hue < 60.0) {
            r = c; g = x; b = 0.0;
        } else if (hue < 120.0) {
            r = x; g = c; b = 0.0;
        } else if (hue < 180.0) {
            r = 0.0; g = c; b = x;
        } else if (hue < 240.0) {
            r = 0.0; g = x; b = c;
        } else if (hue < 300.0) {
            r = x; g = 0.0; b = c;
        } else {
            r = c; g = 0.0; b = x;
        }
        
        return RGBColor() {
            red = (int) Math.round((r + m) * 255.0),
            green = (int) Math.round((g + m) * 255.0),
            blue = (int) Math.round((b + m) * 255.0)
        };
    }
    
    /**
     * Serialize color scheme to JSON string
     */
    public string to_json() {
        var builder = new Json.Builder();
        builder.begin_object();
        
        builder.set_member_name("name");
        builder.add_string_value(name);
        
        builder.set_member_name("piece_colors");
        builder.begin_array();
        foreach (var color in piece_colors) {
            builder.add_string_value(color);
        }
        builder.end_array();
        
        builder.set_member_name("border_color");
        builder.add_string_value(border_color);
        
        builder.set_member_name("border_width");
        builder.add_int_value(border_width);
        
        builder.set_member_name("opacity");
        builder.add_double_value(opacity);
        
        builder.set_member_name("high_contrast");
        builder.add_boolean_value(high_contrast);
        
        builder.set_member_name("is_user_created");
        builder.add_boolean_value(is_user_created);
        
        builder.set_member_name("colorblind_friendly");
        builder.add_boolean_value(colorblind_friendly);
        
        builder.set_member_name("accessibility_profile");
        builder.add_string_value(accessibility_profile);
        
        builder.set_member_name("created_date");
        builder.add_string_value(created_date.format_iso8601());
        
        builder.end_object();
        
        var generator = new Json.Generator();
        generator.set_root(builder.get_root());
        return generator.to_data(null);
    }
    
    /**
     * Create color scheme from JSON string
     */
    public static ColorScheme? from_json(string json_data) throws Error {
        var parser = new Json.Parser();
        parser.load_from_data(json_data);
        
        var root = parser.get_root();
        if (root == null || root.get_node_type() != Json.NodeType.OBJECT) {
            throw new IOError.INVALID_DATA("Invalid JSON format");
        }
        
        var obj = root.get_object();
        var scheme = new ColorScheme();
        
        if (obj.has_member("name")) {
            scheme.name = obj.get_string_member("name");
        }
        
        if (obj.has_member("piece_colors")) {
            var colors_array = obj.get_array_member("piece_colors");
            var colors = new string[colors_array.get_length()];
            for (uint i = 0; i < colors_array.get_length(); i++) {
                colors[i] = colors_array.get_string_element(i);
            }
            scheme.piece_colors = colors;
        }
        
        if (obj.has_member("border_color")) {
            scheme.border_color = obj.get_string_member("border_color");
        }
        
        if (obj.has_member("border_width")) {
            scheme.border_width = (int) obj.get_int_member("border_width");
        }
        
        if (obj.has_member("opacity")) {
            scheme.opacity = obj.get_double_member("opacity");
        }
        
        if (obj.has_member("high_contrast")) {
            scheme.high_contrast = obj.get_boolean_member("high_contrast");
        }
        
        if (obj.has_member("is_user_created")) {
            scheme.is_user_created = obj.get_boolean_member("is_user_created");
        }
        
        if (obj.has_member("colorblind_friendly")) {
            scheme.colorblind_friendly = obj.get_boolean_member("colorblind_friendly");
        }
        
        if (obj.has_member("accessibility_profile")) {
            scheme.accessibility_profile = obj.get_string_member("accessibility_profile");
        }
        
        if (obj.has_member("created_date")) {
            try {
                scheme.created_date = new DateTime.from_iso8601(
                    obj.get_string_member("created_date"), null
                );
            } catch (Error e) {
                scheme.created_date = new DateTime.now_local();
            }
        }
        
        return scheme;
    }
}

/**
 * RGB color representation
 */
public struct RGBColor {
    public int red;
    public int green;
    public int blue;
}

/**
 * Validation result for color schemes
 */
public class ValidationResult : Object {
    public bool is_valid { get; private set; default = true; }
    private GenericArray<string> _errors;
    private GenericArray<string> _warnings;
    
    public string[] errors { 
        get { return _errors.data; }
    }
    
    public string[] warnings { 
        get { return _warnings.data; }
    }
    
    construct {
        _errors = new GenericArray<string>();
        _warnings = new GenericArray<string>();
    }
    
    public void add_error(string message) {
        _errors.add(message);
        is_valid = false;
    }
    
    public void add_warning(string message) {
        _warnings.add(message);
    }
    
    public string get_summary() {
        var builder = new StringBuilder();
        
        if (_errors.length > 0) {
            builder.append("Errors:\n");
            for (uint i = 0; i < _errors.length; i++) {
                builder.append("  - %s\n".printf(_errors[i]));
            }
        }
        
        if (_warnings.length > 0) {
            builder.append("Warnings:\n");
            for (uint i = 0; i < _warnings.length; i++) {
                builder.append("  - %s\n".printf(_warnings[i]));
            }
        }
        
        if (is_valid && _warnings.length == 0) {
            builder.append("Color scheme is valid");
        }
        
        return builder.str;
    }
}

/**
 * Extension methods for string hex validation
 */
public static bool validate_hex_string(string hex_string) {
    foreach (char c in hex_string.to_utf8()) {
        if (!c.isxdigit()) {
            return false;
        }
    }
    return true;
}