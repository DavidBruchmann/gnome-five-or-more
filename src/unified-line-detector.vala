/*
 * Five or More - Unified Line Detection System
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
 * Comprehensive line detection result containing both scoring and visual data
 */
internal class LineDetectionResult : Object {
    public bool has_lines { get; set; default = false; }
    public Gee.HashSet<Cell> cells_to_remove { get; set; }
    public Gee.ArrayList<CompositeLine> visual_lines { get; set; }
    public int score_value { get; set; default = 0; }
    public string description { get; set; default = ""; }
    public bool is_traditional { get; set; default = false; }
    public bool is_composite { get; set; default = false; }
    
    construct {
        cells_to_remove = new Gee.HashSet<Cell>();
        visual_lines = new Gee.ArrayList<CompositeLine>();
    }
    
    public int get_total_cells_count() {
        return cells_to_remove.size;
    }
    
    public bool has_any_lines() {
        return has_lines && cells_to_remove.size > 0;
    }
}

/**
 * Unified line detection engine that replaces both traditional and composite systems
 * Provides single source of truth for all line detection with both scoring and visual data
 */
internal class UnifiedLineDetector : Object {
    private Cell[,] grid;
    private int n_rows;
    private int n_cols;
    private CoordinateValidator validator;
    
    internal UnifiedLineDetector(Cell[,] grid) {
        this.grid = grid;
        this.n_rows = grid.length[0];
        this.n_cols = grid.length[1];
        this.validator = new CoordinateValidator();
    }
    
    /**
     * Single method that provides all line detection results
     * Replaces both get_all_directions() and composite line detection
     */
    internal LineDetectionResult detect_all_lines(int row, int col) {
        var result = new LineDetectionResult();
        
        try {
            // Validate coordinates first
            CoordinateValidator.validate_safe_grid_access(row, col, grid);
            
            var cell = grid[row, col];
            if (cell.piece == null) {
                return result; // No piece at position
            }
            
            // Detect traditional lines (horizontal, vertical, diagonal)
            var traditional_cells = detect_traditional_lines(row, col);
            
            if (traditional_cells.size >= Game.N_MATCH) {
                result.has_lines = true;
                result.is_traditional = true;
                result.cells_to_remove = traditional_cells;
                result.score_value = calculate_traditional_score(traditional_cells.size);
                result.description = "Traditional line: %d pieces".printf(traditional_cells.size);
                return result;
            }
            
            // Check for composite patterns (optional feature)
            // The composite system detects gap-separated patterns (2+3, 3+2, etc.)
            // This is disabled by default to maintain traditional Five-or-More rules
            if (get_game_constants().ENABLE_COMPOSITE_LINES) {
                var composite_lines = detect_composite_lines(row, col);
                
                if (composite_lines.size > 0) {
                    result.has_lines = true;
                    result.is_composite = true;
                    result.visual_lines = composite_lines;
                    result.cells_to_remove = get_composite_line_cells(composite_lines);
                    result.score_value = CompositeScoring.calculate_multiple_lines_score(composite_lines);
                    result.description = CompositeScoring.get_multiple_lines_description(composite_lines, result.score_value);
                    return result;
                }
            }
            
        } catch (CoordinateError e) {
            warning("Line detection failed for position (%d, %d): %s", row, col, e.message);
        }
        
        return result;
    }
    
    /**
     * Detect traditional lines with strict continuity validation
     */
    private Gee.HashSet<Cell> detect_traditional_lines(int row, int col) {
        var all_cells = new Gee.HashSet<Cell>();
        var cell = grid[row, col];
        
        // Check all four directions: horizontal, vertical, two diagonals
        var horizontal_cells = get_bidirectional_continuous_line(row, col, 0, 1, cell.piece.id);
        var vertical_cells = get_bidirectional_continuous_line(row, col, 1, 0, cell.piece.id);
        var diagonal1_cells = get_bidirectional_continuous_line(row, col, 1, 1, cell.piece.id);
        var diagonal2_cells = get_bidirectional_continuous_line(row, col, 1, -1, cell.piece.id);
        
        // Add lines that meet the minimum length requirement
        if (horizontal_cells.size >= Game.N_MATCH) {
            all_cells.add_all(horizontal_cells);
        }
        
        if (vertical_cells.size >= Game.N_MATCH) {
            all_cells.add_all(vertical_cells);
        }
        
        if (diagonal1_cells.size >= Game.N_MATCH) {
            all_cells.add_all(diagonal1_cells);
        }
        
        if (diagonal2_cells.size >= Game.N_MATCH) {
            all_cells.add_all(diagonal2_cells);
        }
        
        return all_cells;
    }
    
    /**
     * Get continuous line in both directions without double-counting the center cell
     */
    private Gee.HashSet<Cell> get_bidirectional_continuous_line(int start_row, int start_col, int dr, int dc, int piece_type) {
        var line_cells = new Gee.HashSet<Cell>();
        
        // Add the starting cell
        line_cells.add(grid[start_row, start_col]);
        
        // Scan in positive direction (excluding starting cell)
        int row = start_row + dr;
        int col = start_col + dc;
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece_type) {
                break;
            }
            line_cells.add(cell);
            row += dr;
            col += dc;
        }
        
        // Scan in negative direction (excluding starting cell)
        row = start_row - dr;
        col = start_col - dc;
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece_type) {
                break;
            }
            line_cells.add(cell);
            row -= dr;
            col -= dc;
        }
        
        return line_cells;
    }
    
    /**
     * Get continuous line in a specific direction using vector math
     * Ensures strict continuity - stops at first gap or foreign piece
     */
    private Gee.HashSet<Cell> get_continuous_line_in_direction(int start_row, int start_col, int dr, int dc, int piece_type) {
        var line_cells = new Gee.HashSet<Cell>();
        
        int row = start_row;
        int col = start_col;
        
        // Scan in the direction until we hit a boundary, gap, or foreign piece
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            
            // Stop if no piece or different piece type
            if (cell.piece == null || cell.piece.id != piece_type) {
                break;
            }
            
            line_cells.add(cell);
            
            // Move to next position in direction
            row += dr;
            col += dc;
        }
        
        return line_cells;
    }
    
    /**
     * Enhanced boundary checking with coordinate validation
     */
    private bool is_valid_position(int row, int col) {
        try {
            CoordinateValidator.validate_grid_access(row, col, n_rows, n_cols);
            return true;
        } catch (CoordinateError e) {
            return false;
        }
    }
    
    /**
     * Detect composite lines using direct implementation (no circular dependency)
     */
    private Gee.ArrayList<CompositeLine> detect_composite_lines(int row, int col) {
        var composite_lines = new Gee.ArrayList<CompositeLine>();
        
        var cell = grid[row, col];
        if (cell.piece == null) {
            return composite_lines;
        }
        
        // Check all four directions for composite patterns
        var horizontal_line = detect_composite_line_in_direction(row, col, 0, 1, cell.piece.id);
        if (horizontal_line != null && horizontal_line.total_length >= Game.N_MATCH) {
            composite_lines.add(horizontal_line);
        }
        
        var vertical_line = detect_composite_line_in_direction(row, col, 1, 0, cell.piece.id);
        if (vertical_line != null && vertical_line.total_length >= Game.N_MATCH) {
            composite_lines.add(vertical_line);
        }
        
        var diagonal1_line = detect_composite_line_in_direction(row, col, 1, 1, cell.piece.id);
        if (diagonal1_line != null && diagonal1_line.total_length >= Game.N_MATCH) {
            composite_lines.add(diagonal1_line);
        }
        
        var diagonal2_line = detect_composite_line_in_direction(row, col, 1, -1, cell.piece.id);
        if (diagonal2_line != null && diagonal2_line.total_length >= Game.N_MATCH) {
            composite_lines.add(diagonal2_line);
        }
        
        return composite_lines;
    }
    
    /**
     * Detect composite line in a specific direction with strict continuity validation
     */
    private CompositeLine? detect_composite_line_in_direction(int start_row, int start_col, int dr, int dc, int piece_type) {
        var segments = new Gee.ArrayList<LineSegment>();
        
        // Find all continuous segments in both directions from the starting point
        var forward_segments = find_continuous_segments_in_direction(start_row, start_col, dr, dc, piece_type);
        var backward_segments = find_continuous_segments_in_direction(start_row, start_col, -dr, -dc, piece_type);
        
        // Combine segments, avoiding duplication of the starting point
        foreach (var segment in backward_segments) {
            segments.add(segment);
        }
        
        foreach (var segment in forward_segments) {
            segments.add(segment);
        }
        
        if (segments.size == 0) {
            return null;
        }
        
        // Create composite line
        var composite_line = new CompositeLine();
        
        // Sort segments by position to ensure proper order
        segments.sort((a, b) => {
            if (dr != 0) {
                return a.start_row - b.start_row;
            } else {
                return a.start_col - b.start_col;
            }
        });
        
        foreach (var segment in segments) {
            composite_line.add_segment(segment);
        }
        
        return composite_line;
    }
    
    /**
     * Find continuous segments in one direction with strict gap validation
     */
    private Gee.ArrayList<LineSegment> find_continuous_segments_in_direction(int start_row, int start_col, int dr, int dc, int piece_type) {
        var segments = new Gee.ArrayList<LineSegment>();
        
        int current_row = start_row;
        int current_col = start_col;
        
        while (true) {
            // Find the start of the next continuous segment
            var segment_start = find_next_segment_start(current_row, current_col, dr, dc, piece_type);
            if (segment_start == null) {
                break;
            }
            
            // Find the end of this continuous segment
            var segment_end = find_segment_end(segment_start.row, segment_start.col, dr, dc, piece_type);
            
            // Count actual continuous pieces with strict validation
            int segment_length = count_strictly_continuous_pieces(segment_start.row, segment_start.col, 
                                                                segment_end.row, segment_end.col, dr, dc, piece_type);
            
            if (segment_length >= 2) { // Minimum segment size for composite lines
                var segment = new LineSegment(segment_start.row, segment_start.col,
                                            segment_end.row, segment_end.col,
                                            segment_length, piece_type);
                segments.add(segment);
            }
            
            // Move to next potential segment position
            current_row = segment_end.row + dr;
            current_col = segment_end.col + dc;
        }
        
        return segments;
    }
    
    /**
     * Find the start of the next segment of matching pieces
     */
    private Cell? find_next_segment_start(int start_row, int start_col, int dr, int dc, int piece_type) {
        int row = start_row;
        int col = start_col;
        
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            if (cell.piece != null && cell.piece.id == piece_type) {
                return cell;
            }
            
            row += dr;
            col += dc;
        }
        
        return null;
    }
    
    /**
     * Find the end of a continuous segment
     */
    private Cell find_segment_end(int start_row, int start_col, int dr, int dc, int piece_type) {
        int row = start_row;
        int col = start_col;
        int last_valid_row = start_row;
        int last_valid_col = start_col;
        
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece_type) {
                break;
            }
            
            last_valid_row = row;
            last_valid_col = col;
            row += dr;
            col += dc;
        }
        
        return grid[last_valid_row, last_valid_col];
    }
    
    /**
     * Count strictly continuous matching pieces - prevents phantom lines
     */
    private int count_strictly_continuous_pieces(int start_row, int start_col, int end_row, int end_col, int dr, int dc, int piece_type) {
        int count = 0;
        int row = start_row;
        int col = start_col;
        
        // Count pieces step by step to ensure strict continuity
        while (is_valid_position(row, col)) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece_type) {
                break; // Stop at first gap or different piece - prevents phantom lines
            }
            
            count++;
            
            // Stop if we've reached the end position
            if (row == end_row && col == end_col) {
                break;
            }
            
            row += dr;
            col += dc;
        }
        
        return count;
    }
    
    /**
     * Get all cells from composite lines for removal
     */
    private Gee.HashSet<Cell> get_composite_line_cells(Gee.ArrayList<CompositeLine> composite_lines) {
        var cells_to_remove = new Gee.HashSet<Cell>();
        
        foreach (var composite_line in composite_lines) {
            foreach (var segment in composite_line.segments) {
                var segment_cells = segment.get_cells();
                foreach (var cell in segment_cells) {
                    // Find the actual cell from the grid
                    var grid_cell = grid[cell.row, cell.col];
                    cells_to_remove.add(grid_cell);
                }
            }
        }
        
        return cells_to_remove;
    }
    
    /**
     * Calculate traditional line score
     */
    private int calculate_traditional_score(int line_length) {
        var constants = get_game_constants();
        return (int) (constants.SCORE_BASE_MULTIPLIER * Math.log(constants.SCORE_LOG_FACTOR * line_length));
    }
    
    /**
     * Get debug information for a position
     */
    internal string get_debug_info(int row, int col) {
        var debug_info = new StringBuilder();
        
        try {
            CoordinateValidator.validate_safe_grid_access(row, col, grid);
            
            var cell = grid[row, col];
            debug_info.append("Position: (%d, %d)\n".printf(row, col));
            
            if (cell.piece == null) {
                debug_info.append("No piece at position\n");
                return debug_info.str;
            }
            
            debug_info.append("Piece type: %d\n".printf(cell.piece.id));
            
            // Check each direction
            var horizontal = get_continuous_line_in_direction(row, col, 0, 1, cell.piece.id);
            horizontal.add_all(get_continuous_line_in_direction(row, col, 0, -1, cell.piece.id));
            debug_info.append("Horizontal: %d pieces\n".printf(horizontal.size));
            
            var vertical = get_continuous_line_in_direction(row, col, 1, 0, cell.piece.id);
            vertical.add_all(get_continuous_line_in_direction(row, col, -1, 0, cell.piece.id));
            debug_info.append("Vertical: %d pieces\n".printf(vertical.size));
            
            var diagonal1 = get_continuous_line_in_direction(row, col, 1, 1, cell.piece.id);
            diagonal1.add_all(get_continuous_line_in_direction(row, col, -1, -1, cell.piece.id));
            debug_info.append("Diagonal 1: %d pieces\n".printf(diagonal1.size));
            
            var diagonal2 = get_continuous_line_in_direction(row, col, 1, -1, cell.piece.id);
            diagonal2.add_all(get_continuous_line_in_direction(row, col, -1, 1, cell.piece.id));
            debug_info.append("Diagonal 2: %d pieces\n".printf(diagonal2.size));
            
            debug_info.append("Required: %d pieces\n".printf(Game.N_MATCH));
            
            var result = detect_all_lines(row, col);
            if (result.has_any_lines()) {
                debug_info.append("VALID LINE DETECTED!\n");
                debug_info.append("Type: %s\n".printf(result.is_traditional ? "Traditional" : "Composite"));
                debug_info.append("Cells to remove: %d\n".printf(result.get_total_cells_count()));
                debug_info.append("Score: %d\n".printf(result.score_value));
            } else {
                debug_info.append("No valid lines\n");
            }
            
        } catch (CoordinateError e) {
            debug_info.append("Error: %s\n".printf(e.message));
        }
        
        return debug_info.str;
    }
}