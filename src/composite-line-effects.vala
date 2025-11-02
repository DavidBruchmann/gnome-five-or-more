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
 * Represents a segment in a composite line
 */
public class LineSegment : Object {
    public int start_row { get; set; }
    public int start_col { get; set; }
    public int end_row { get; set; }
    public int end_col { get; set; }
    public int length { get; set; }
    public int piece_type { get; set; }
    
    public LineSegment(int start_row, int start_col, int end_row, int end_col, int length, int piece_type) {
        this.start_row = start_row;
        this.start_col = start_col;
        this.end_row = end_row;
        this.end_col = end_col;
        this.length = length;
        this.piece_type = piece_type;
    }
    
    /**
     * Get all cells in this segment
     */
    internal Gee.ArrayList<Cell> get_cells() {
        var cells = new Gee.ArrayList<Cell>();
        
        int dr = (end_row - start_row) / (length - 1);
        int dc = (end_col - start_col) / (length - 1);
        
        for (int i = 0; i < length; i++) {
            int row = start_row + i * dr;
            int col = start_col + i * dc;
            cells.add(new Cell(row, col, null, null));
        }
        
        return cells;
    }
}

/**
 * Represents a composite line made of multiple segments
 */
public class CompositeLine : Object {
    public Gee.ArrayList<LineSegment> segments { get; private set; }
    public int total_length { get; private set; }
    public int piece_type { get; private set; }
    
    construct {
        segments = new Gee.ArrayList<LineSegment>();
        total_length = 0;
    }
    
    public void add_segment(LineSegment segment) {
        segments.add(segment);
        total_length += segment.length;
        piece_type = segment.piece_type;
    }
    
    /**
     * Get description of the composite line pattern
     */
    public string get_pattern_description() {
        if (segments.size == 1) {
            return @"$(total_length) in a row";
        }
        
        var pattern = new StringBuilder();
        for (int i = 0; i < segments.size; i++) {
            if (i > 0) pattern.append("+");
            pattern.append(segments[i].length.to_string());
        }
        pattern.append(@" combo ($(total_length) total)");
        
        return pattern.str;
    }
    
    /**
     * Calculate bonus score for this composite pattern
     */
    public int calculate_bonus_score() {
        if (segments.size <= 1) {
            return 0; // No bonus for single segments
        }
        
        var constants = get_game_constants();
        int base_bonus = constants.COMPOSITE_BASE_BONUS;
        int complexity_bonus = segments.size * constants.COMPOSITE_COMPLEXITY_BONUS;
        
        // Balance bonus - reward more balanced segments
        int min_length = int.MAX;
        int max_length = 0;
        
        foreach (var segment in segments) {
            min_length = int.min(min_length, segment.length);
            max_length = int.max(max_length, segment.length);
        }
        
        int balance_bonus = (max_length - min_length) <= 1 ? 25 : 10;
        
        return base_bonus + complexity_bonus + balance_bonus;
    }
}

/**
 * Animation phases for composite line completion
 */
public enum CompletionPhase {
    HIGHLIGHTING,
    CONNECTING,
    CLEARING,
    COMPLETE
}

/**
 * Manages visual effects for composite lines
 */
public class CompositeLineEffects : Object {
    private LayeredRenderer renderer;
    private Gee.ArrayList<CompositeLine> active_lines;
    private HashTable<string, CompositeLineState> piece_states;
    private uint animation_timer_id = 0;
    private CompletionPhase current_phase = CompletionPhase.COMPLETE;
    private double animation_progress = 0.0;
    
    // Animation timing constants (now configurable)
    private static int ANIMATION_DURATION_MS { get { return get_game_constants().ANIMATION_DURATION_MS; } }
    private static int ANIMATION_FRAME_MS { get { return get_game_constants().ANIMATION_FRAME_MS; } }
    
    public signal void animation_complete(CompositeLine line, int bonus_score);
    public signal void redraw_needed();
    
    construct {
        active_lines = new Gee.ArrayList<CompositeLine>();
        piece_states = new HashTable<string, CompositeLineState>(str_hash, str_equal);
    }
    
    internal void set_renderer(LayeredRenderer renderer) {
        this.renderer = renderer;
    }
    
    /**
     * Start composite line completion animation
     */
    public void animate_composite_line_completion(CompositeLine line) {
        active_lines.add(line);
        
        // Set up piece states for the composite line
        setup_piece_states(line);
        
        // Start animation
        current_phase = CompletionPhase.HIGHLIGHTING;
        animation_progress = 0.0;
        
        if (animation_timer_id != 0) {
            Source.remove(animation_timer_id);
        }
        
        animation_timer_id = Timeout.add(ANIMATION_FRAME_MS, animate_frame);
    }
    
    /**
     * Set up piece states for composite line visualization
     */
    private void setup_piece_states(CompositeLine line) {
        piece_states.remove_all();
        
        for (int seg_idx = 0; seg_idx < line.segments.size; seg_idx++) {
            var segment = line.segments[seg_idx];
            var cells = segment.get_cells();
            
            for (int cell_idx = 0; cell_idx < cells.size; cell_idx++) {
                var cell = cells[cell_idx];
                string key = @"$(cell.row),$(cell.col)";
                
                CompositeLineState state;
                
                if (seg_idx == 0 && cell_idx == 0) {
                    // First piece of first segment
                    state = CompositeLineState.SEGMENT_START;
                } else if (seg_idx == line.segments.size - 1 && cell_idx == cells.size - 1) {
                    // Last piece of last segment
                    state = CompositeLineState.SEGMENT_END;
                } else if (cell_idx == 0 || cell_idx == cells.size - 1) {
                    // Segment boundary pieces
                    state = CompositeLineState.CONNECTING;
                } else {
                    // Regular pieces in segments
                    state = CompositeLineState.NONE;
                }
                
                piece_states.insert(key, state);
            }
        }
    }
    
    /**
     * Animation frame callback
     */
    private bool animate_frame() {
        animation_progress += (double)ANIMATION_FRAME_MS / ANIMATION_DURATION_MS;
        
        if (animation_progress >= 1.0) {
            // Move to next phase or complete
            switch (current_phase) {
                case CompletionPhase.HIGHLIGHTING:
                    current_phase = CompletionPhase.CONNECTING;
                    animation_progress = 0.0;
                    break;
                    
                case CompletionPhase.CONNECTING:
                    current_phase = CompletionPhase.CLEARING;
                    animation_progress = 0.0;
                    break;
                    
                case CompletionPhase.CLEARING:
                    current_phase = CompletionPhase.COMPLETE;
                    complete_animation();
                    return Source.REMOVE;
            }
        }
        
        redraw_needed();
        return Source.CONTINUE;
    }
    
    /**
     * Complete the animation and clean up
     */
    private void complete_animation() {
        foreach (var line in active_lines) {
            int bonus_score = line.calculate_bonus_score();
            animation_complete(line, bonus_score);
        }
        
        active_lines.clear();
        piece_states.remove_all();
        animation_timer_id = 0;
    }
    
    /**
     * Get the composite line state for a piece at given position
     */
    public CompositeLineState get_piece_state(int row, int col) {
        string key = @"$(row),$(col)";
        return piece_states.contains(key) ? piece_states.lookup(key) : CompositeLineState.NONE;
    }
    
    /**
     * Check if animations are currently running
     */
    public bool is_animating() {
        return animation_timer_id != 0;
    }
    
    /**
     * Get current animation phase
     */
    public CompletionPhase get_current_phase() {
        return current_phase;
    }
    
    /**
     * Get animation progress (0.0 to 1.0)
     */
    public double get_animation_progress() {
        return animation_progress;
    }
    
    /**
     * Render connection arcs between segments
     */
    public void render_connection_arcs(Cairo.Context cr, CompositeLine line, int piece_size) {
        if (current_phase != CompletionPhase.CONNECTING) {
            return;
        }
        
        cr.save();
        
        // Set up arc rendering
        cr.set_line_width(3.0);
        cr.set_source_rgba(1.0, 1.0, 0.0, 0.8 * animation_progress); // Yellow arcs
        
        // Draw arcs between segments
        for (int i = 0; i < line.segments.size - 1; i++) {
            var seg1 = line.segments[i];
            var seg2 = line.segments[i + 1];
            
            // Get end point of first segment and start point of second segment
            double x1 = seg1.end_col * piece_size + piece_size / 2.0;
            double y1 = seg1.end_row * piece_size + piece_size / 2.0;
            double x2 = seg2.start_col * piece_size + piece_size / 2.0;
            double y2 = seg2.start_row * piece_size + piece_size / 2.0;
            
            // Calculate arc control points
            double mid_x = (x1 + x2) / 2.0;
            double mid_y = (y1 + y2) / 2.0;
            double offset = piece_size * 0.3;
            
            // Draw curved connection
            cr.move_to(x1, y1);
            cr.curve_to(x1 + offset, y1 - offset, x2 - offset, y2 - offset, x2, y2);
            cr.stroke();
            
            // Draw arrow at connection point
            render_connection_arrow(cr, mid_x, mid_y, x2 - x1, y2 - y1);
        }
        
        cr.restore();
    }
    
    /**
     * Render arrow indicating connection direction
     */
    private void render_connection_arrow(Cairo.Context cr, double x, double y, double dx, double dy) {
        double length = Math.sqrt(dx * dx + dy * dy);
        if (length < 0.001) return;
        
        // Normalize direction
        dx /= length;
        dy /= length;
        
        double arrow_size = 8.0;
        
        cr.save();
        cr.translate(x, y);
        
        // Draw arrow head
        cr.move_to(0, 0);
        cr.line_to(-arrow_size * dx - arrow_size * dy * 0.5, -arrow_size * dy + arrow_size * dx * 0.5);
        cr.line_to(-arrow_size * dx + arrow_size * dy * 0.5, -arrow_size * dy - arrow_size * dx * 0.5);
        cr.close_path();
        cr.fill();
        
        cr.restore();
    }
    
    /**
     * Create score popup animation data
     */
    public ScorePopup create_score_popup(CompositeLine line, int bonus_score, int piece_size) {
        // Calculate center position of the composite line
        double center_x = 0;
        double center_y = 0;
        int total_pieces = 0;
        
        foreach (var segment in line.segments) {
            var cells = segment.get_cells();
            foreach (var cell in cells) {
                center_x += cell.col * piece_size + piece_size / 2.0;
                center_y += cell.row * piece_size + piece_size / 2.0;
                total_pieces++;
            }
        }
        
        center_x /= total_pieces;
        center_y /= total_pieces;
        
        return new ScorePopup(center_x, center_y, line.get_pattern_description(), bonus_score);
    }
    
    /**
     * Stop all animations
     */
    public void stop_animations() {
        if (animation_timer_id != 0) {
            Source.remove(animation_timer_id);
            animation_timer_id = 0;
        }
        
        active_lines.clear();
        piece_states.remove_all();
        current_phase = CompletionPhase.COMPLETE;
    }
}

/**
 * Score popup animation data
 */
public class ScorePopup : Object {
    public double x { get; set; }
    public double y { get; set; }
    public string description { get; set; }
    public int score { get; set; }
    public double opacity { get; set; default = 1.0; }
    public double scale { get; set; default = 1.0; }
    
    public ScorePopup(double x, double y, string description, int score) {
        this.x = x;
        this.y = y;
        this.description = description;
        this.score = score;
    }
    
    /**
     * Render the score popup
     */
    public void render(Cairo.Context cr) {
        cr.save();
        
        cr.translate(x, y);
        cr.scale(scale, scale);
        
        // Draw background
        cr.set_source_rgba(0, 0, 0, 0.8 * opacity);
        cr.rectangle(-60, -25, 120, 50);
        cr.fill();
        
        // Draw border
        cr.set_source_rgba(1, 1, 1, opacity);
        cr.set_line_width(2);
        cr.rectangle(-60, -25, 120, 50);
        cr.stroke();
        
        // Draw text
        cr.set_source_rgba(1, 1, 1, opacity);
        cr.select_font_face("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size(12);
        
        // Score text
        var score_text = @"+$(score)";
        Cairo.TextExtents extents;
        cr.text_extents(score_text, out extents);
        cr.move_to(-extents.width / 2, -5);
        cr.show_text(score_text);
        
        // Description text
        cr.set_font_size(10);
        cr.text_extents(description, out extents);
        cr.move_to(-extents.width / 2, 10);
        cr.show_text(description);
        
        cr.restore();
    }
}