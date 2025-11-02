/*
 * Basic test for coordinate validation
 */

// Test coordinate validation errors
internal errordomain CoordinateError {
    OUT_OF_BOUNDS,
    DIMENSION_MISMATCH,
    INVALID_MAPPING,
    INVALID_BOARD_SIZE
}

// Basic coordinate validation
internal class BasicCoordinateValidator : Object {
    
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
}

int main(string[] args) {
    print("Testing Basic Coordinate Validation\n");
    print("==================================\n\n");
    
    // Test 1: Grid access validation
    print("Test 1: Grid Access Validation\n");
    try {
        BasicCoordinateValidator.validate_grid_access(0, 0, 9, 9); // Valid
        print("✓ Valid grid access (0,0) in 9x9 grid passed\n");
        
        BasicCoordinateValidator.validate_grid_access(8, 8, 9, 9); // Valid edge
        print("✓ Valid edge access (8,8) in 9x9 grid passed\n");
        
        // Test out of bounds
        try {
            BasicCoordinateValidator.validate_grid_access(9, 9, 9, 9); // Out of bounds
            print("✗ Should have failed for out of bounds access\n");
        } catch (CoordinateError e) {
            print("✓ Correctly caught out of bounds access: %s\n", e.message);
        }
        
        try {
            BasicCoordinateValidator.validate_grid_access(-1, 0, 9, 9); // Negative
            print("✗ Should have failed for negative coordinates\n");
        } catch (CoordinateError e) {
            print("✓ Correctly caught negative coordinates: %s\n", e.message);
        }
    } catch (CoordinateError e) {
        print("✗ Unexpected error in grid access validation: %s\n", e.message);
    }
    
    print("\n");
    
    // Test 2: Line direction validation
    print("Test 2: Line Direction Validation\n");
    bool horizontal = BasicCoordinateValidator.is_valid_line_direction(0, 0, 0, 4);
    print("✓ Horizontal line (0,0) to (0,4): %s\n", horizontal ? "valid" : "invalid");
    
    bool vertical = BasicCoordinateValidator.is_valid_line_direction(0, 0, 4, 0);
    print("✓ Vertical line (0,0) to (4,0): %s\n", vertical ? "valid" : "invalid");
    
    bool diagonal = BasicCoordinateValidator.is_valid_line_direction(0, 0, 3, 3);
    print("✓ Diagonal line (0,0) to (3,3): %s\n", diagonal ? "valid" : "invalid");
    
    bool invalid_line = BasicCoordinateValidator.is_valid_line_direction(0, 0, 2, 3);
    print("✓ Invalid line (0,0) to (2,3): %s\n", invalid_line ? "valid" : "invalid");
    
    bool same_position = BasicCoordinateValidator.is_valid_line_direction(0, 0, 0, 0);
    print("✓ Same position (0,0) to (0,0): %s\n", same_position ? "valid" : "invalid");
    
    print("\nBasic coordinate validation tests completed!\n");
    
    return 0;
}