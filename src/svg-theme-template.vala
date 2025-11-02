/*
 * Five or More - SVG Theme Template Engine
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
 * Interface for theme template engines that can generate themes from color schemes
 */
public interface IThemeTemplate : Object {
    /**
     * Generate a theme handle from a color scheme
     * @param scheme The color scheme to apply
     * @return An Rsvg.Handle containing the generated theme
     * @throws Error if theme generation fails
     */
    public abstract Rsvg.Handle generate_theme(ColorScheme scheme) throws Error;
    
    /**
     * Get list of supported animation types
     * @return Array of animation type names
     */
    public abstract string[] get_supported_animations();
    
    /**
     * Invalidate the internal cache, forcing regeneration on next request
     */
    public abstract void invalidate_cache();
}

/**
 * SVG-based theme template engine that generates themes by substituting CSS variables
 */
public class SVGThemeTemplate : Object, IThemeTemplate {
    private string base_template;
    private HashTable<string, Rsvg.Handle> cache;
    private bool template_loaded = false;
    
    // Template validation patterns
    private const string[] REQUIRED_CSS_VARS = {
        "--piece-color-0", "--piece-color-1", "--piece-color-2", "--piece-color-3",
        "--piece-color-4", "--piece-color-5", "--piece-color-6",
        "--border-color", "--border-width"
    };
    
    private const string[] SUPPORTED_ANIMATIONS = {
        "normal", "shrinking", "growing", "pulsing"
    };
    
    construct {
        cache = new HashTable<string, Rsvg.Handle>(str_hash, str_equal);
    }
    
    /**
     * Load the base SVG template from embedded resources or file system
     */
    private void load_base_template() throws Error {
        if (template_loaded) {
            return;
        }
        
        // Try to load from embedded resources first
        try {
            var resource = resources_lookup_data("/org/gnome/five-or-more/themes/template.svg", ResourceLookupFlags.NONE);
            base_template = (string) resource.get_data();
            template_loaded = true;
            return;
        } catch (Error e) {
            debug("Failed to load embedded template: %s", e.message);
        }
        
        // Fallback to file system
        var template_file = Path.build_filename(DATA_DIRECTORY, "themes", "template.svg");
        try {
            FileUtils.get_contents(template_file, out base_template);
            template_loaded = true;
        } catch (FileError e) {
            // Create a minimal fallback template if no template is found
            base_template = create_fallback_template();
            template_loaded = true;
            warning("Using fallback template: %s", e.message);
        }
        
        validate_template();
    }
    
    /**
     * Create a minimal fallback SVG template
     */
    private string create_fallback_template() {
        var constants = get_game_constants();
        return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" version="1.1">""".printf(constants.SVG_TEMPLATE_WIDTH, constants.SVG_TEMPLATE_HEIGHT) + """
  <style>
    :root {
      --piece-color-0: #FFFF00;
      --piece-color-1: #FF00FF;
      --piece-color-2: #00FF00;
      --piece-color-3: #FF0000;
      --piece-color-4: #0000FF;
      --piece-color-5: #00FFFF;
      --piece-color-6: #FF8000;
      --border-color: #000000;
      --border-width: 5;
    }
    .piece { stroke: var(--border-color); stroke-width: var(--border-width); }
    .piece-0 { fill: var(--piece-color-0); }
    .piece-1 { fill: var(--piece-color-1); }
    .piece-2 { fill: var(--piece-color-2); }
    .piece-3 { fill: var(--piece-color-3); }
    .piece-4 { fill: var(--piece-color-4); }
    .piece-5 { fill: var(--piece-color-5); }
    .piece-6 { fill: var(--piece-color-6); }
  </style>
  <g>
    <!-- Normal animation frames -->
    <circle class="piece piece-0" cx="50" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="150" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="250" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="350" cy="50" r="37.5"/>
    
    <circle class="piece piece-1" cx="50" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="150" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="250" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="350" cy="150" r="37.5"/>
    
    <circle class="piece piece-2" cx="50" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="150" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="250" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="350" cy="250" r="37.5"/>
    
    <circle class="piece piece-3" cx="50" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="150" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="250" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="350" cy="350" r="37.5"/>
    
    <circle class="piece piece-4" cx="50" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="150" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="250" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="350" cy="450" r="37.5"/>
    
    <circle class="piece piece-5" cx="50" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="150" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="250" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="350" cy="550" r="37.5"/>
    
    <circle class="piece piece-6" cx="50" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="150" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="250" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="350" cy="650" r="37.5"/>
  </g>
</svg>""";
    }
    
    /**
     * Validate that the template contains required CSS variables
     */
    private void validate_template() throws Error {
        foreach (var required_var in REQUIRED_CSS_VARS) {
            if (!base_template.contains(required_var)) {
                throw new IOError.INVALID_DATA(
                    "Template missing required CSS variable: %s".printf(required_var)
                );
            }
        }
    }
    
    /**
     * Generate a cache key for a color scheme
     */
    private string generate_cache_key(ColorScheme scheme) {
        var key_builder = new StringBuilder();
        key_builder.append(scheme.name);
        key_builder.append(":");
        
        foreach (var color in scheme.piece_colors) {
            key_builder.append(color);
            key_builder.append(",");
        }
        
        key_builder.append(scheme.border_color);
        key_builder.append(":");
        key_builder.append(scheme.border_width.to_string());
        key_builder.append(":");
        key_builder.append(scheme.opacity.to_string());
        
        return key_builder.str;
    }
    
    /**
     * Substitute CSS variables in the template with color scheme values
     */
    private string substitute_css_variables(ColorScheme scheme) {
        var result = base_template;
        
        // Substitute piece colors
        for (int i = 0; i < scheme.piece_colors.length && i < 7; i++) {
            var css_var = "--piece-color-%d".printf(i);
            result = result.replace(css_var, scheme.piece_colors[i]);
        }
        
        // Substitute border properties
        result = result.replace("--border-color", scheme.border_color);
        result = result.replace("--border-width", scheme.border_width.to_string());
        
        return result;
    }
    
    /**
     * Generate a theme handle from a color scheme
     */
    public Rsvg.Handle generate_theme(ColorScheme scheme) throws Error {
        load_base_template();
        
        var cache_key = generate_cache_key(scheme);
        
        // Check cache first
        var cached_handle = cache.lookup(cache_key);
        if (cached_handle != null) {
            return cached_handle;
        }
        
        // Generate new theme
        var substituted_svg = substitute_css_variables(scheme);
        
        try {
            var handle = new Rsvg.Handle.from_data(substituted_svg.data);
            
            // Cache the result
            cache.insert(cache_key, handle);
            
            return handle;
        } catch (Error e) {
            throw new IOError.INVALID_DATA(
                "Failed to create SVG handle from generated theme: %s".printf(e.message)
            );
        }
    }
    
    /**
     * Get list of supported animation types
     */
    public string[] get_supported_animations() {
        return SUPPORTED_ANIMATIONS;
    }
    
    /**
     * Invalidate the internal cache
     */
    public void invalidate_cache() {
        cache.remove_all();
    }
    
    /**
     * Get cache statistics for debugging
     */
    public uint get_cache_size() {
        return cache.size();
    }
    
    /**
     * Clear cache entries older than specified time
     */
    public void cleanup_cache(TimeSpan max_age = TimeSpan.HOUR) {
        // For now, just clear all cache entries
        // In a more sophisticated implementation, we would track timestamps
        cache.remove_all();
    }
}