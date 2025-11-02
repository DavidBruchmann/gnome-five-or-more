/*
 * Five or More - Resource Validation and Integrity Checking
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
 * Resource validation result
 */
public class ResourceValidationResult : Object {
    public bool is_valid { get; set; }
    public string resource_name { get; set; }
    public uint64 resource_size { get; set; }
    public string checksum { get; set; }
    
    private Gee.List<string> error_list;
    private Gee.List<string> warning_list;
    
    construct {
        error_list = new Gee.ArrayList<string>();
        warning_list = new Gee.ArrayList<string>();
        is_valid = true;
    }
    
    public void add_error(string error) {
        error_list.add(error);
        is_valid = false;
    }
    
    public void add_warning(string warning) {
        warning_list.add(warning);
    }
    
    public string[] get_errors() {
        return error_list.to_array();
    }
    
    public string[] get_warnings() {
        return warning_list.to_array();
    }
}

/**
 * Resource validator for embedded and external resources
 */
public class ResourceValidator : Object {
    private static ResourceValidator? instance = null;
    
    // Expected resource checksums for integrity checking
    private HashTable<string, string> expected_checksums;
    
    // Required SVG elements for theme validation
    private const string[] REQUIRED_SVG_ELEMENTS = {
        "svg", "style", "circle", "defs"
    };
    
    // Required CSS variables for theme templates
    private const string[] REQUIRED_CSS_VARIABLES = {
        "--piece-color-0", "--piece-color-1", "--piece-color-2", "--piece-color-3",
        "--piece-color-4", "--piece-color-5", "--piece-color-6",
        "--border-color", "--border-width"
    };
    
    construct {
        expected_checksums = new HashTable<string, string>(str_hash, str_equal);
        initialize_expected_checksums();
    }
    
    public static ResourceValidator get_instance() {
        if (instance == null) {
            instance = new ResourceValidator();
        }
        return instance;
    }
    
    /**
     * Initialize expected checksums for critical resources
     */
    private void initialize_expected_checksums() {
        // These would be updated during build process with actual checksums
        // For now, we'll compute them dynamically
    }
    
    /**
     * Validate embedded resource integrity
     */
    public ResourceValidationResult validate_embedded_resource(string resource_path) {
        var result = new ResourceValidationResult();
        result.resource_name = resource_path;
        
        try {
            var resource_data = resources_lookup_data(resource_path, ResourceLookupFlags.NONE);
            result.resource_size = resource_data.length;
            result.checksum = compute_checksum(resource_data.get_data());
            
            // Check if resource exists and has content
            if (resource_data.length == 0) {
                result.add_error("Resource is empty");
                return result;
            }
            
            // Validate based on resource type
            if (resource_path.has_suffix(".svg")) {
                validate_svg_content(resource_data.get_data(), result);
            } else if (resource_path.has_suffix(".xml")) {
                validate_xml_content(resource_data.get_data(), result);
            }
            
            // Check integrity if we have expected checksum
            var expected_checksum = expected_checksums.lookup(resource_path);
            if (expected_checksum != null && expected_checksum != result.checksum) {
                result.add_error("Resource integrity check failed - checksum mismatch");
            }
            
        } catch (Error e) {
            result.add_error("Failed to load embedded resource: %s".printf(e.message));
        }
        
        return result;
    }
    
    /**
     * Validate external file resource
     */
    public ResourceValidationResult validate_file_resource(string file_path) {
        var result = new ResourceValidationResult();
        result.resource_name = file_path;
        
        var file = File.new_for_path(file_path);
        
        try {
            if (!file.query_exists()) {
                result.add_error("File does not exist");
                return result;
            }
            
            var file_info = file.query_info(
                FileAttribute.STANDARD_SIZE + "," + FileAttribute.TIME_MODIFIED,
                FileQueryInfoFlags.NONE
            );
            
            result.resource_size = file_info.get_size();
            
            // Check file size limits
            if (result.resource_size > 10 * 1024 * 1024) { // 10MB limit
                result.add_error("File too large (>10MB)");
                return result;
            }
            
            if (result.resource_size == 0) {
                result.add_error("File is empty");
                return result;
            }
            
            // Load and validate content
            uint8[] contents;
            file.load_contents(null, out contents, null);
            result.checksum = compute_checksum(contents);
            
            // Validate based on file type
            if (file_path.has_suffix(".svg")) {
                validate_svg_content(contents, result);
            } else if (file_path.has_suffix(".xml")) {
                validate_xml_content(contents, result);
            }
            
        } catch (Error e) {
            result.add_error("Failed to validate file: %s".printf(e.message));
        }
        
        return result;
    }
    
    /**
     * Validate SVG content for theme compatibility
     */
    private void validate_svg_content(uint8[] content, ResourceValidationResult result) {
        var content_str = (string) content;
        
        // Check for required SVG elements
        foreach (var element in REQUIRED_SVG_ELEMENTS) {
            if (!content_str.contains("<%s".printf(element))) {
                result.add_error("Missing required SVG element: %s".printf(element));
            }
        }
        
        // Check for CSS variables (for template themes)
        bool has_css_vars = false;
        foreach (var css_var in REQUIRED_CSS_VARIABLES) {
            if (content_str.contains(css_var)) {
                has_css_vars = true;
                break;
            }
        }
        
        if (!has_css_vars) {
            result.add_warning("SVG does not appear to be a template (no CSS variables found)");
        } else {
            // Validate all required CSS variables are present
            foreach (var css_var in REQUIRED_CSS_VARIABLES) {
                if (!content_str.contains(css_var)) {
                    result.add_error("Missing required CSS variable: %s".printf(css_var));
                }
            }
        }
        
        // Check SVG structure
        if (!content_str.contains("xmlns=\"http://www.w3.org/2000/svg\"")) {
            result.add_error("Invalid SVG: missing SVG namespace");
        }
        
        // Validate that SVG can be parsed
        try {
            var handle = new Rsvg.Handle.from_data(content);
            double width, height;
            handle.get_intrinsic_size_in_pixels(out width, out height);
            
            if (width <= 0 || height <= 0) {
                result.add_error("SVG has invalid dimensions");
            }
            
            // Check for reasonable dimensions (not too small or too large)
            if (width < 100 || height < 100) {
                result.add_warning("SVG dimensions are very small (%gx%g)".printf(width, height));
            }
            
            if (width > 2000 || height > 2000) {
                result.add_warning("SVG dimensions are very large (%gx%g)".printf(width, height));
            }
            
        } catch (Error e) {
            result.add_error("SVG parsing failed: %s".printf(e.message));
        }
    }
    
    /**
     * Validate XML content
     */
    private void validate_xml_content(uint8[] content, ResourceValidationResult result) {
        var content_str = (string) content;
        
        // Basic XML validation
        if (!content_str.contains("<?xml")) {
            result.add_warning("XML declaration missing");
        }
        
        // Basic XML structure validation
        if (!content_str.contains("<") || !content_str.contains(">")) {
            result.add_error("XML structure is invalid - missing angle brackets");
        }
        
        // Check for balanced tags (simple validation)
        var open_tags = 0;
        var close_tags = 0;
        for (int i = 0; i < content_str.length - 1; i++) {
            if (content_str[i] == '<' && content_str[i + 1] != '/') {
                open_tags++;
            } else if (content_str[i] == '<' && content_str[i + 1] == '/') {
                close_tags++;
            }
        }
        
        if (open_tags != close_tags) {
            result.add_warning("XML may have unbalanced tags");
        }
    }
    
    /**
     * Compute SHA-256 checksum for integrity checking
     */
    private string compute_checksum(uint8[] data) {
        var checksum = new Checksum(ChecksumType.SHA256);
        checksum.update(data, data.length);
        return checksum.get_string();
    }
    
    /**
     * Validate all embedded resources
     */
    public ResourceValidationResult[] validate_all_embedded_resources() {
        var results = new Gee.ArrayList<ResourceValidationResult>();
        
        // List of known embedded resources to validate
        string[] embedded_resources = {
            "/org/gnome/five-or-more/themes/template.svg",
            "/org/gnome/five-or-more/ui/five-or-more.ui",
            "/org/gnome/five-or-more/gtk/help-overlay.ui"
        };
        
        foreach (var resource_path in embedded_resources) {
            var result = validate_embedded_resource(resource_path);
            results.add(result);
        }
        
        return results.to_array();
    }
    
    /**
     * Generate validation report
     */
    public string generate_validation_report(ResourceValidationResult[] results) {
        var builder = new StringBuilder();
        builder.append("Resource Validation Report\n");
        builder.append("=========================\n\n");
        
        int valid_count = 0;
        int invalid_count = 0;
        int warning_count = 0;
        
        foreach (var result in results) {
            builder.append("Resource: %s\n".printf(result.resource_name));
            builder.append("  Status: %s\n".printf(result.is_valid ? "VALID" : "INVALID"));
            builder.append("  Size: %llu bytes\n".printf(result.resource_size));
            builder.append("  Checksum: %s\n".printf(result.checksum));
            
            var errors = result.get_errors();
            var warnings = result.get_warnings();
            
            if (errors.length > 0) {
                builder.append("  Errors:\n");
                foreach (var error in errors) {
                    builder.append("    - %s\n".printf(error));
                }
                invalid_count++;
            } else {
                valid_count++;
            }
            
            if (warnings.length > 0) {
                builder.append("  Warnings:\n");
                foreach (var warning in warnings) {
                    builder.append("    - %s\n".printf(warning));
                }
                warning_count++;
            }
            
            builder.append("\n");
        }
        
        builder.append("Summary:\n");
        builder.append("  Valid resources: %d\n".printf(valid_count));
        builder.append("  Invalid resources: %d\n".printf(invalid_count));
        builder.append("  Resources with warnings: %d\n".printf(warning_count));
        builder.append("  Total resources: %d\n".printf(results.length));
        
        return builder.str;
    }
    
    /**
     * Update expected checksum for a resource
     */
    public void set_expected_checksum(string resource_path, string checksum) {
        expected_checksums.insert(resource_path, checksum);
    }
    
    /**
     * Export checksums for build system integration
     */
    public void export_checksums(string file_path) throws Error {
        var builder = new StringBuilder();
        builder.append("# Five or More Resource Checksums\n");
        builder.append("# Generated automatically - do not edit manually\n\n");
        
        expected_checksums.foreach((resource, checksum) => {
            builder.append("%s=%s\n".printf(resource, checksum));
        });
        
        FileUtils.set_contents(file_path, builder.str);
    }
    
    /**
     * Import checksums from build system
     */
    public void import_checksums(string file_path) throws Error {
        if (!FileUtils.test(file_path, FileTest.EXISTS)) {
            return;
        }
        
        string content;
        FileUtils.get_contents(file_path, out content);
        
        var lines = content.split("\n");
        foreach (var line in lines) {
            line = line.strip();
            if (line.length == 0 || line.has_prefix("#")) {
                continue;
            }
            
            var parts = line.split("=", 2);
            if (parts.length == 2) {
                expected_checksums.insert(parts[0], parts[1]);
            }
        }
    }
}