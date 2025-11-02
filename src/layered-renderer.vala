/*
 * Color lines for GNOME
 * Copyright © 1999 Free Software Foundation
 * Authors: Robert Szokovacs <szo@szo.hu>
 *          Szabolcs Ban <shooby@gnome.hu>
 *          Karuna Grewal <karunagrewal98@gmail.com>
 *          Ruxandra Simion <ruxandra.simion93@gmail.com>
 * Copyright © 2007 Christian Persch
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
 * Animation states for pieces
 */
public enum AnimationState {
    NORMAL = 0,
    SHRINKING = 1,
    GROWING = 2,
    PULSING = 3
}

/**
 * Special composite line states for enhanced visual effects
 */
public enum CompositeLineState {
    NONE,
    SEGMENT_START,
    SEGMENT_END,
    CONNECTING
}

/**
 * LayeredRenderer provides efficient rendering using colored backgrounds with SVG overlays
 */
internal class LayeredRenderer : Object {
    private Rsvg.Handle? overlay_template = null;
    private HashTable<string, Cairo.Pattern> background_cache;
    private HashTable<string, Cairo.Surface> overlay_cache;
    private ColorScheme current_color_scheme;
    private bool cache_valid = false;
    
    // Rendering constants
    private const double DEFAULT_RADIUS = 37.5;
    private const double SHRINKING_SCALE = 0.9;
    private const double GROWING_SCALE = 1.1;
    
    // Color scheme for pieces
    private string[] piece_colors = {
        "#FFFF00", // Yellow
        "#FF00FF", // Magenta  
        "#00FF00", // Green
        "#FF0000", // Red
        "#0000FF", // Blue
        "#00FFFF", // Cyan
        "#FF8000"  // Orange
    };
    
    construct {
        background_cache = new HashTable<string, Cairo.Pattern>(str_hash, str_equal);
        overlay_cache = new HashTable<string, Cairo.Surface>(str_hash, str_equal);
        
        // Initialize with default color scheme
        current_color_scheme = new ColorScheme();
        current_color_scheme.piece_colors = piece_colors;
        current_color_scheme.border_color = "#000000";
        current_color_scheme.border_width = 2;
        current_color_scheme.opacity = 1.0;
        
        load_overlay_template();
    }
    
    /**
     * Load the SVG overlay template
     */
    private void load_overlay_template() {
        try {
            var overlay_file = Path.build_filename(DATA_DIRECTORY, "overlay-template.svg");
            overlay_template = new Rsvg.Handle.from_file(overlay_file);
        } catch (Error e) {
            warning("Failed to load overlay template: %s", e.message);
            // Continue without overlay - will render basic colored circles
        }
    }
    
    /**
     * Update the color scheme and invalidate caches
     */
    public void set_color_scheme(ColorScheme scheme) {
        current_color_scheme = scheme;
        invalidate_cache();
    }
    
    /**
     * Invalidate all caches when theme changes
     */
    public void invalidate_cache() {
        background_cache.remove_all();
        overlay_cache.remove_all();
        cache_valid = false;
    }
    
    /**
     * Get cached background pattern for a piece type
     */
    private Cairo.Pattern get_background_pattern(int piece_type, int size, AnimationState animation) {
        var cache_key = @"bg_$(piece_type)_$(size)_$(animation)";
        var cached_pattern = background_cache.lookup(cache_key);
        
        if (cached_pattern != null) {
            return cached_pattern;
        }
        
        // Create colored background surface
        var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, size, size);
        var cr = new Cairo.Context(surface);
        
        // Calculate radius based on animation state
        double radius = get_game_constants().DEFAULT_PIECE_RADIUS * size / get_game_constants().THEME_SPRITE_BASE_SIZE;
        switch (animation) {
            case AnimationState.SHRINKING:
                radius *= SHRINKING_SCALE;
                break;
            case AnimationState.GROWING:
                radius *= GROWING_SCALE;
                break;
        }
        
        // Draw colored circle background
        cr.set_source_rgba(0, 0, 0, 0); // Transparent background
        cr.paint();
        
        // Parse piece color
        Gdk.RGBA color = Gdk.RGBA();
        if (piece_type < current_color_scheme.piece_colors.length && 
            color.parse(current_color_scheme.piece_colors[piece_type])) {
            cr.set_source_rgba(color.red, color.green, color.blue, 
                              color.alpha * current_color_scheme.opacity);
        } else {
            // Fallback color
            cr.set_source_rgba(0.5, 0.5, 0.5, current_color_scheme.opacity);
        }
        
        // Draw the colored circle
        cr.arc(size / 2.0, size / 2.0, radius, 0, 2 * Math.PI);
        cr.fill();
        
        // Create pattern from surface
        var pattern = new Cairo.Pattern.for_surface(surface);
        background_cache.insert(cache_key, pattern);
        
        return pattern;
    }
    
    /**
     * Get cached overlay surface for a piece type and animation
     */
    private Cairo.Surface? get_overlay_surface(int piece_type, int size, AnimationState animation, 
                                             CompositeLineState composite_state = CompositeLineState.NONE) {
        var cache_key = @"overlay_$(piece_type)_$(size)_$(animation)_$(composite_state)";
        var cached_surface = overlay_cache.lookup(cache_key);
        
        if (cached_surface != null) {
            return cached_surface;
        }
        
        if (overlay_template == null) {
            return null; // No overlay available
        }
        
        // Create overlay surface
        var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, size, size);
        var cr = new Cairo.Context(surface);
        
        // Scale to fit the requested size
        var scale = size / (double)get_game_constants().THEME_SPRITE_BASE_SIZE;
        cr.scale(scale, scale);
        
        // Calculate source position in the overlay template
        var sprite_size = get_game_constants().THEME_SPRITE_BASE_SIZE;
        int source_x = (int)animation * sprite_size; // Animation columns
        int source_y = piece_type * sprite_size;     // Piece type rows
        
        // Set up clipping and translation for the specific piece
        cr.rectangle(0, 0, sprite_size, sprite_size);
        cr.clip();
        cr.translate(-source_x, -source_y);
        
        // Render the overlay
        try {
            overlay_template.render_cairo(cr);
        } catch (Error e) {
            warning("Failed to render overlay: %s", e.message);
            return null;
        }
        
        // Add composite line state effects if needed
        if (composite_state != CompositeLineState.NONE) {
            render_composite_line_effect(cr, composite_state, scale);
        }
        
        overlay_cache.insert(cache_key, surface);
        return surface;
    }
    
    /**
     * Render special effects for composite line states
     */
    private void render_composite_line_effect(Cairo.Context cr, CompositeLineState state, double scale) {
        cr.save();
        cr.identity_matrix();
        cr.scale(scale, scale);
        
        double radius = DEFAULT_RADIUS;
        double center_x = 50;
        double center_y = 50;
        
        switch (state) {
            case CompositeLineState.SEGMENT_START:
                // Cyan glow for segment start
                cr.set_source_rgba(0, 1, 1, 0.6);
                cr.set_line_width(3);
                cr.arc(center_x, center_y, radius + 2, 0, 2 * Math.PI);
                cr.stroke();
                break;
                
            case CompositeLineState.SEGMENT_END:
                // Yellow glow for segment end
                cr.set_source_rgba(1, 1, 0, 0.6);
                cr.set_line_width(3);
                cr.arc(center_x, center_y, radius + 2, 0, 2 * Math.PI);
                cr.stroke();
                break;
                
            case CompositeLineState.CONNECTING:
                // Magenta glow for connecting pieces
                cr.set_source_rgba(1, 0, 1, 0.6);
                cr.set_line_width(3);
                cr.arc(center_x, center_y, radius + 2, 0, 2 * Math.PI);
                cr.stroke();
                break;
        }
        
        cr.restore();
    }
    
    /**
     * Render a piece with layered approach: colored background + SVG overlay
     */
    public void render_piece(Cairo.Context cr, int piece_type, AnimationState animation, 
                           double x, double y, int size, 
                           CompositeLineState composite_state = CompositeLineState.NONE) {
        
        if (piece_type < 0 || piece_type >= Game.N_TYPES) {
            return; // Invalid piece type
        }
        
        cr.save();
        
        // Render colored background
        var bg_pattern = get_background_pattern(piece_type, size, animation);
        cr.set_source(bg_pattern);
        
        var matrix = Cairo.Matrix.identity();
        matrix.translate(-x, -y);
        bg_pattern.set_matrix(matrix);
        
        cr.rectangle(x, y, size, size);
        cr.fill();
        
        // Render SVG overlay if available
        var overlay_surface = get_overlay_surface(piece_type, size, animation, composite_state);
        if (overlay_surface != null) {
            cr.set_source_surface(overlay_surface, x, y);
            cr.rectangle(x, y, size, size);
            cr.fill();
        }
        
        cr.restore();
    }
    
    /**
     * Render a piece using the legacy animation state integer
     */
    public void render_sprite(Cairo.Context cr, int piece_type, int animation_int, 
                            double x, double y, int size) {
        AnimationState animation = (AnimationState) (animation_int % 4);
        render_piece(cr, piece_type, animation, x, y, size);
    }
    
    /**
     * Pre-render pieces for better performance
     */
    public void pre_render_pieces(int size) {
        for (int type = 0; type < Game.N_TYPES; type++) {
            for (int anim = 0; anim < Game.N_ANIMATIONS; anim++) {
                AnimationState animation = (AnimationState) anim;
                
                // Pre-cache background patterns
                get_background_pattern(type, size, animation);
                
                // Pre-cache overlay surfaces
                get_overlay_surface(type, size, animation);
                
                // Pre-cache composite line state overlays
                get_overlay_surface(type, size, animation, CompositeLineState.SEGMENT_START);
                get_overlay_surface(type, size, animation, CompositeLineState.SEGMENT_END);
                get_overlay_surface(type, size, animation, CompositeLineState.CONNECTING);
            }
        }
        cache_valid = true;
    }
    
    /**
     * Get memory usage statistics for debugging
     */
    public string get_cache_stats() {
        return @"LayeredRenderer Cache: $(background_cache.size()) backgrounds, $(overlay_cache.size()) overlays";
    }
    
    /**
     * Check if caches are valid
     */
    public bool is_cache_valid() {
        return cache_valid;
    }
}

