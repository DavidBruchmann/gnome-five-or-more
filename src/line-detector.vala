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
 * Detects composite lines on the game board
 */
internal class LineDetector : Object {
    private Cell[,] grid;
    private int n_rows;
    private int n_cols;
    
    internal LineDetector(Cell[,] grid) {
        this.grid = grid;
        this.n_rows = grid.length[0];
        this.n_cols = grid.length[1];
    }
    
    /**
     * Detect all composite lines starting from a given position
     */
    internal Gee.ArrayList<CompositeLine> detect_composite_lines(int row, int col) {
        var composite_lines = new Gee.ArrayList<CompositeLine>();
        
        var piece = grid[row, col].piece;
        if (piece == null) {
            return composite_lines;
        }
        
        // Check all four directions
        var horizontal_line = detect_composite_line_in_direction(row, col, 0, 1, piece.id);
        if (horizontal_line != null && horizontal_line.total_length >= Game.N_MATCH) {
            composite_lines.add(horizontal_line);
        }
        
        var vertical_line = detect_composite_line_in_direction(row, col, 1, 0, piece.id);
        if (vertical_line != null && vertical_line.total_length >= Game.N_MATCH) {
            composite_lines.add(vertical_line);
        }
        
        var diagonal1_line = detect_composite_line_in_direction(row, col, 1, 1, piece.id);
        if (diagonal1_line != null && diagonal1_line.total_length >= Game.N_MATCH) {
            composite_lines.add(diagonal1_line);
        }
        
        var diagonal2_line = detect_composite_line_in_direction(row, col, 1, -1, piece.id);
        if (diagonal2_line != null && diagonal2_line.total_length >= Game.N_MATCH) {
            composite_lines.add(diagonal2_line);
        }
        
        return composite_lines;
    }
    
    /**
     * Detect composite line in a specific direction
     */
    private CompositeLine? detect_composite_line_in_direction(int start_row, int start_col, int dr, int dc, int piece_type) {
        var segments = new Gee.ArrayList<LineSegment>();
        
        // Find all segments in both directions from the starting point
        var forward_segments = find_segments_in_direction(start_row, start_col, dr, dc, piece_type);
        var backward_segments = find_segments_in_direction(start_row, start_col, -dr, -dc, piece_type);
        
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
     * Find continuous segments in one direction (no gaps allowed)
     */
    private Gee.ArrayList<LineSegment> find_segments_in_direction(int start_row, int start_col, int dr, int dc, int piece_type) {
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
            
            // Count actual continuous pieces, not coordinate distance
            int segment_length = count_continuous_pieces(segment_start.row, segment_start.col, 
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
            var piece = grid[row, col].piece;
            if (piece != null && piece.id == piece_type) {
                return grid[row, col];
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
            var piece = grid[row, col].piece;
            if (piece == null || piece.id != piece_type) {
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
     * Count continuous matching pieces between start and end positions
     * This prevents phantom lines by validating every position
     */
    private int count_continuous_pieces(int start_row, int start_col, int end_row, int end_col, int dr, int dc, int piece_type) {
        int count = 0;
        int row = start_row;
        int col = start_col;
        
        // Count pieces step by step to ensure continuity
        while (is_valid_position(row, col)) {
            var piece = grid[row, col].piece;
            if (piece == null || piece.id != piece_type) {
                break; // Stop at first gap or different piece
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
     * Check if position is valid on the board
     */
    private bool is_valid_position(int row, int col) {
        return row >= 0 && row < n_rows && col >= 0 && col < n_cols;
    }
    
    /**
     * Get all cells that should be removed for traditional 5-in-a-row detection
     * Uses fixed line detection logic instead of buggy get_all_directions
     */
    internal Gee.HashSet<Cell> get_traditional_lines(int row, int col) {
        // Use the fixed UnifiedLineDetector instead of buggy get_all_directions
        var unified_detector = new UnifiedLineDetector(grid);
        var result = unified_detector.detect_all_lines(row, col);
        
        if (result.is_traditional) {
            return result.cells_to_remove;
        }
        
        return new Gee.HashSet<Cell>();
    }
    
    /**
     * Get all cells from composite lines for removal
     */
    internal Gee.HashSet<Cell> get_composite_line_cells(Gee.ArrayList<CompositeLine> composite_lines) {
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
}