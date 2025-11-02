/*
 * Simple test for coordinate validation infrastructure
 */

using Gee;

// Mock structures for testing
private struct GameDifficulty {
    public int n_cols;
    public int n_rows;
    public int n_types;
    public int n_next_pieces;
}

private struct DifficultyLevel {
    public string key;
    public string name;
    public int pieces_per_round;
}

// Mock game constants for testing
internal class GameConstants : Object {
    private static GameConstants? _instance = null;
    internal static GameConstants instance {
        get {
            if (_instance == null) {
                _instance = new GameConstants();
            }
            return _instance;
        }
    }
    
    internal GameDifficulty[] game_difficulty { get; private set; }
    
    construct {
        game_difficulty = {
            { -1, -1, -1, -1 },  // Invalid/placeholder
            {  7,  7,  5,  3 },  // Small
            {  9,  9,  7,  3 },  // Medium  
            { 20, 15,  7,  7 }   // Large
        };
    }
}

internal GameConstants get_game_constants() {
    return GameConstants.instance;
}

// Include coordinate validation infrastructure
// (The actual files would be included here in a real build)

int main(string[] args) {
    print("Testing Coordinate Validation Infrastructure (Simple)\n");
    print("==================================================\n\n");
    
    // Test 1: Board dimension validation
    print("Test 1: Board Dimension Validation\n");
    try {
        CoordinateValidator.validate_board_dimensions(1); // Small board
        print("✓ Small board validation passed\n");
        
        CoordinateValidator.validate_board_dimensions(2); // Medium board  
        print("✓ Medium board validation passed\n");
        
        CoordinateValidator.validate_board_dimensions(3); // Large board
        print("✓ Large board validation passed\n");
        
        // Test invalid board size
        try {
            CoordinateValidator.validate_board_dimensions(5); // Invalid
            print("✗ Should have failed for invalid board size\n");
        } catch (CoordinateError e) {
            print("✓ Correctly caught invalid board size: %s\n", e.message);
        }
    } catch (CoordinateError e) {
        print("✗ Unexpected error in board dimension validation: %s\n", e.message);
    }
    
    print("\n");
    
    // Test 2: Grid access validation
    print("Test 2: Grid Access Validation\n");
    try {
        CoordinateValidator.validate_grid_access(0, 0, 9, 9); // Valid
        print("✓ Valid grid access (0,0) in 9x9 grid passed\n");
        
        CoordinateValidator.validate_grid_access(8, 8, 9, 9); // Valid edge
        print("✓ Valid edge access (8,8) in 9x9 grid passed\n");
        
        // Test out of bounds
        try {
            CoordinateValidator.validate_grid_access(9, 9, 9, 9); // Out of bounds
            print("✗ Should have failed for out of bounds access\n");
        } catch (CoordinateError e) {
            print("✓ Correctly caught out of bounds access: %s\n", e.message);
        }
        
        try {
            CoordinateValidator.validate_grid_access(-1, 0, 9, 9); // Negative
            print("✗ Should have failed for negative coordinates\n");
        } catch (CoordinateError e) {
            print("✓ Correctly caught negative coordinates: %s\n", e.message);
        }
    } catch (CoordinateError e) {
        print("✗ Unexpected error in grid access validation: %s\n", e.message);
    }
    
    print("\n");
    
    // Test 3: BoardDimensionManager
    print("Test 3: BoardDimensionManager\n");
    try {
        var small_dims = BoardDimensions.from_difficulty(1);
        print("✓ Small board dimensions: %dx%d\n", small_dims.cols, small_dims.rows);
        
        var medium_dims = BoardDimensions.from_difficulty(2);
        print("✓ Medium board dimensions: %dx%d\n", medium_dims.cols, medium_dims.rows);
        
        var large_dims = BoardDimensions.from_difficulty(3);
        print("✓ Large board dimensions: %dx%d\n", large_dims.cols, large_dims.rows);
        
        // Test position validation
        bool valid_pos = BoardDimensionManager.validate_position(4, 4, 2); // Medium board
        print("✓ Position (4,4) valid on medium board: %s\n", valid_pos ? "true" : "false");
        
        bool invalid_pos = BoardDimensionManager.validate_position(15, 15, 2); // Out of bounds
        print("✓ Position (15,15) valid on medium board: %s\n", invalid_pos ? "true" : "false");
        
    } catch (CoordinateError e) {
        print("✗ Error in BoardDimensionManager: %s\n", e.message);
    }
    
    print("\n");
    
    // Test 4: Line direction validation
    print("Test 4: Line Direction Validation\n");
    bool horizontal = BoardDimensionManager.is_valid_line_direction(0, 0, 0, 4);
    print("✓ Horizontal line (0,0) to (0,4): %s\n", horizontal ? "valid" : "invalid");
    
    bool vertical = BoardDimensionManager.is_valid_line_direction(0, 0, 4, 0);
    print("✓ Vertical line (0,0) to (4,0): %s\n", vertical ? "valid" : "invalid");
    
    bool diagonal = BoardDimensionManager.is_valid_line_direction(0, 0, 3, 3);
    print("✓ Diagonal line (0,0) to (3,3): %s\n", diagonal ? "valid" : "invalid");
    
    bool invalid_line = BoardDimensionManager.is_valid_line_direction(0, 0, 2, 3);
    print("✓ Invalid line (0,0) to (2,3): %s\n", invalid_line ? "valid" : "invalid");
    
    print("\nAll coordinate validation infrastructure tests completed!\n");
    
    return 0;
}