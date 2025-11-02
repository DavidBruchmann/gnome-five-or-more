/*
 * Five or More - Coordinate Validation Infrastructure
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
 * Coordinate validation errors
 */
internal errordomain CoordinateError {
    OUT_OF_BOUNDS,
    DIMENSION_MISMATCH,
    INVALID_MAPPING,
    INVALID_BOARD_SIZE
}

/**
 * Coordinate validation infrastructure for ensuring consistent coordinate usage
 */
internal class CoordinateValidator : Object {
    
    /**
     * Validate board dimensions for a given size
     */
    public static bool validate_board_dimensions(int size) throws CoordinateError {
        var constants = get_game_constants();
        
        if (size < 1 || size >= constants.game_difficulty.length) {
            throw new CoordinateError.INVALID_BOARD_SIZE(
                "Invalid board size: %d (valid range: 1-%d)".printf(
                    size, constants.game_difficulty.length - 1
                )
            );
        }
        
        var difficulty = constants.game_difficulty[size];
        
        if (difficulty.n_rows <= 0 || difficulty.n_cols <= 0) {
            throw new CoordinateError.DIMENSION_MISMATCH(
                "Invalid dimensions for size %d: %dx%d".printf(
                    size, difficulty.n_cols, difficulty.n_rows
                )
            );
        }
        
        if (difficulty.n_rows > 50 || difficulty.n_cols > 50) {
            throw new CoordinateError.DIMENSION_MISMATCH(
                "Dimensions too large for size %d: %dx%d (max: 50x50)".printf(
                    size, difficulty.n_cols, difficulty.n_rows
                )
            );
        }
        
        return true;
    }
    
    /**
     * Validate grid access coordinates
     */
    public static bool validate_grid_access(int row, int col, int n_rows, int n_cols) throws CoordinateError {
        if (row < 0 || row >= n_rows) {
            throw new CoordinateError.OUT_OF_BOUNDS(
                "Row %d out of bounds (valid range: 0-%d)".printf(
                    row, n_rows - 1
                )
            );
        }
        
        if (col < 0 || col >= n_cols) {
            throw new CoordinateError.OUT_OF_BOUNDS(
                "Column %d out of bounds (valid range: 0-%d)".printf(
                    col, n_cols - 1
                )
            );
        }
        
        return true;
    }
    
    /**
     * Validate coordinate consistency across game components
     */
    public static bool validate_coordinate_consistency(Game game) throws CoordinateError {
        if (game.board == null) {
            throw new CoordinateError.INVALID_MAPPING(
                "Board is null - cannot validate coordinates"
            );
        }
        
        var constants = get_game_constants();
        var expected_difficulty = constants.game_difficulty[game.get_board_size()];
        
        // Check that board dimensions match expected dimensions from GameDifficulty
        if (game.board.n_rows != expected_difficulty.n_rows) {
            throw new CoordinateError.DIMENSION_MISMATCH(
                "Board rows mismatch: expected %d, got %d".printf(
                    expected_difficulty.n_rows, game.board.n_rows
                )
            );
        }
        
        if (game.board.n_cols != expected_difficulty.n_cols) {
            throw new CoordinateError.DIMENSION_MISMATCH(
                "Board columns mismatch: expected %d, got %d".printf(
                    expected_difficulty.n_cols, game.board.n_cols
                )
            );
        }
        
        return true;
    }
    
    /**
     * Validate that coordinates are within safe bounds for grid operations
     */
    public static bool validate_safe_grid_access(int row, int col, Cell[,]? grid) throws CoordinateError {
        if (grid == null) {
            throw new CoordinateError.INVALID_MAPPING(
                "Grid is null - cannot validate access"
            );
        }
        
        int n_rows = grid.length[0];
        int n_cols = grid.length[1];
        
        return validate_grid_access(row, col, n_rows, n_cols);
    }
    
    /**
     * Validate coordinate mapping between visual and logical systems
     */
    public static bool validate_coordinate_mapping(int visual_x, int visual_y, 
                                                 int logical_row, int logical_col,
                                                 int board_size) throws CoordinateError {
        try {
            validate_board_dimensions(board_size);
        } catch (CoordinateError e) {
            throw new CoordinateError.INVALID_MAPPING(
                "Invalid board size: %s".printf(e.message)
            );
        }
        
        var constants = get_game_constants();
        var difficulty = constants.game_difficulty[board_size];
        
        // Validate logical coordinates are within bounds
        try {
            validate_grid_access(logical_row, logical_col, difficulty.n_rows, difficulty.n_cols);
        } catch (CoordinateError e) {
            throw new CoordinateError.INVALID_MAPPING(
                "Invalid logical coordinates: %s".printf(e.message)
            );
        }
        
        // Visual coordinates should be non-negative
        if (visual_x < 0 || visual_y < 0) {
            throw new CoordinateError.INVALID_MAPPING(
                "Visual coordinates cannot be negative: (%d, %d)".printf(visual_x, visual_y)
            );
        }
        
        return true;
    }
    
    /**
     * Validate line detection coordinates and direction
     */
    public static bool validate_line_detection_params(int start_row, int start_col, 
                                                    int end_row, int end_col,
                                                    Cell[,] grid) throws CoordinateError {
        validate_safe_grid_access(start_row, start_col, grid);
        validate_safe_grid_access(end_row, end_col, grid);
        
        // Validate that start and end form a valid line (horizontal, vertical, or diagonal)
        int dr = end_row - start_row;
        int dc = end_col - start_col;
        
        if (dr == 0 && dc == 0) {
            throw new CoordinateError.INVALID_MAPPING(
                "Start and end coordinates are identical: (%d, %d)".printf(start_row, start_col)
            );
        }
        
        // Check if it's a valid line direction
        bool is_horizontal = (dr == 0 && dc != 0);
        bool is_vertical = (dr != 0 && dc == 0);
        bool is_diagonal = (dr.abs() == dc.abs() && dr != 0 && dc != 0);
        
        if (!is_horizontal && !is_vertical && !is_diagonal) {
            throw new CoordinateError.INVALID_MAPPING(
                "Invalid line direction from (%d, %d) to (%d, %d)".printf(
                    start_row, start_col, end_row, end_col
                )
            );
        }
        
        return true;
    }
}