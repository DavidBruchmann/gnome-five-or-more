/*
 * Five or More - Board Dimension Management
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
 * Board dimensions structure with explicit row/column mapping
 */
internal struct BoardDimensions {
    public int rows;
    public int cols;
    public int piece_types;
    public int next_pieces;
    
    /**
     * Create BoardDimensions from GameDifficulty with explicit mapping
     */
    public static BoardDimensions from_difficulty(int size) throws CoordinateError {
        CoordinateValidator.validate_board_dimensions(size);
        
        var constants = get_game_constants();
        var difficulty = constants.game_difficulty[size];
        
        return BoardDimensions() {
            rows = difficulty.n_rows,        // Explicit mapping
            cols = difficulty.n_cols,        // Explicit mapping  
            piece_types = difficulty.n_types,
            next_pieces = difficulty.n_next_pieces
        };
    }
    
    /**
     * Validate that these dimensions are consistent
     */
    public bool validate() {
        return rows > 0 && cols > 0 && 
               piece_types > 0 && next_pieces > 0 &&
               rows <= 50 && cols <= 50;
    }
    
    /**
     * Get total number of cells
     */
    public int get_total_cells() {
        return rows * cols;
    }
    
    /**
     * Check if position is within bounds
     */
    public bool contains_position(int row, int col) {
        return row >= 0 && row < rows && col >= 0 && col < cols;
    }
}

/**
 * Centralized board dimension management and coordinate mapping
 */
internal class BoardDimensionManager : Object {
    
    /**
     * Get board dimensions with validation
     */
    public static void get_board_dimensions(int size, out int n_rows, out int n_cols) throws CoordinateError {
        var dimensions = BoardDimensions.from_difficulty(size);
        n_rows = dimensions.rows;
        n_cols = dimensions.cols;
    }
    
    /**
     * Validate position against board size
     */
    public static bool validate_position(int row, int col, int size) {
        try {
            var dimensions = BoardDimensions.from_difficulty(size);
            return dimensions.contains_position(row, col);
        } catch (CoordinateError e) {
            warning("Failed to validate position (%d, %d) for size %d: %s", 
                   row, col, size, e.message);
            return false;
        }
    }
    
    /**
     * Map visual coordinates to logical board coordinates
     */
    public static void map_visual_to_logical(int visual_x, int visual_y, 
                                           out int logical_row, out int logical_col,
                                           int board_size) throws CoordinateError {
        // For now, assume 1:1 mapping - this can be enhanced later for different visual layouts
        logical_row = visual_y;
        logical_col = visual_x;
        
        // Validate the mapping
        CoordinateValidator.validate_coordinate_mapping(
            visual_x, visual_y, logical_row, logical_col, board_size
        );
    }
    
    /**
     * Map logical board coordinates to visual coordinates  
     */
    public static void map_logical_to_visual(int logical_row, int logical_col,
                                           out int visual_x, out int visual_y,
                                           int board_size) throws CoordinateError {
        // Validate input coordinates first
        var dimensions = BoardDimensions.from_difficulty(board_size);
        CoordinateValidator.validate_grid_access(logical_row, logical_col, 
                                               dimensions.rows, dimensions.cols);
        
        // For now, assume 1:1 mapping - this can be enhanced later for different visual layouts
        visual_x = logical_col;
        visual_y = logical_row;
    }
    
    /**
     * Get safe grid access with bounds checking
     */
    public static Cell? get_safe_cell(Cell[,] grid, int row, int col) {
        try {
            CoordinateValidator.validate_safe_grid_access(row, col, grid);
            return grid[row, col];
        } catch (CoordinateError e) {
            warning("Safe grid access failed for (%d, %d): %s", row, col, e.message);
            return null;
        }
    }
    
    /**
     * Set piece with coordinate validation
     */
    public static bool set_safe_piece(Cell[,] grid, int row, int col, Piece? piece) {
        try {
            CoordinateValidator.validate_safe_grid_access(row, col, grid);
            grid[row, col].piece = piece;
            return true;
        } catch (CoordinateError e) {
            warning("Safe piece setting failed for (%d, %d): %s", row, col, e.message);
            return false;
        }
    }
    
    /**
     * Get piece with coordinate validation
     */
    public static Piece? get_safe_piece(Cell[,] grid, int row, int col) {
        var cell = get_safe_cell(grid, row, col);
        return cell != null ? cell.piece : null;
    }
    
    /**
     * Validate board creation parameters
     */
    public static bool validate_board_creation_params(int size, int n_rows, int n_cols) {
        try {
            var expected_dimensions = BoardDimensions.from_difficulty(size);
            
            if (n_rows != expected_dimensions.rows) {
                warning("Board creation parameter mismatch: expected %d rows, got %d", 
                       expected_dimensions.rows, n_rows);
                return false;
            }
            
            if (n_cols != expected_dimensions.cols) {
                warning("Board creation parameter mismatch: expected %d cols, got %d", 
                       expected_dimensions.cols, n_cols);
                return false;
            }
            
            return true;
        } catch (CoordinateError e) {
            warning("Board creation validation failed: %s", e.message);
            return false;
        }
    }
    
    /**
     * Get validated dimensions for board creation
     */
    public static BoardDimensions get_validated_dimensions(int size) throws CoordinateError {
        return BoardDimensions.from_difficulty(size);
    }
    
    /**
     * Check if two positions form a valid line direction
     */
    public static bool is_valid_line_direction(int start_row, int start_col, 
                                             int end_row, int end_col) {
        int dr = end_row - start_row;
        int dc = end_col - start_col;
        
        if (dr == 0 && dc == 0) {
            return false; // Same position
        }
        
        // Check if it's horizontal, vertical, or diagonal
        bool is_horizontal = (dr == 0 && dc != 0);
        bool is_vertical = (dr != 0 && dc == 0);
        bool is_diagonal = (dr.abs() == dc.abs() && dr != 0 && dc != 0);
        
        return is_horizontal || is_vertical || is_diagonal;
    }
    
    /**
     * Calculate distance between two positions
     */
    public static int calculate_position_distance(int start_row, int start_col,
                                                int end_row, int end_col) {
        int dr = (end_row - start_row).abs();
        int dc = (end_col - start_col).abs();
        
        // Return the maximum of row and column differences (Chebyshev distance)
        return int.max(dr, dc);
    }
    
    /**
     * Get all valid neighbor positions for a given cell
     */
    public static Gee.ArrayList<Cell> get_valid_neighbors(Cell[,] grid, int row, int col) {
        var neighbors = new Gee.ArrayList<Cell>();
        
        // Check all 8 directions
        int[] dr = {-1, -1, -1,  0,  0,  1,  1,  1};
        int[] dc = {-1,  0,  1, -1,  1, -1,  0,  1};
        
        for (int i = 0; i < 8; i++) {
            int new_row = row + dr[i];
            int new_col = col + dc[i];
            
            var neighbor = get_safe_cell(grid, new_row, new_col);
            if (neighbor != null) {
                neighbors.add(neighbor);
            }
        }
        
        return neighbors;
    }
}