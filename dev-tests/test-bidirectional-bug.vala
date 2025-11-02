/*
 * Test to investigate the "two pieces on both sides" phantom line bug
 */

using Gee;

void main() {
    print("=== Bidirectional Line Bug Investigation ===\n");
    
    // Test the specific pattern: pieces with gaps that require 2+ on each side
    test_bidirectional_pattern();
    test_edge_cases();
}

void test_bidirectional_pattern() {
    print("\n--- Testing Bidirectional Pattern ---\n");
    
    // Create a test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Test case 1: 2 pieces - gap - 1 piece - gap - 2 pieces (should NOT be valid)
    print("Test 1: 2-gap-1-gap-2 pattern (should be invalid)\n");
    setup_pattern_1(grid);
    test_line_detection(grid, 4, 4, "Pattern 1");
    clear_grid(grid);
    
    // Test case 2: 2 pieces - gap - 2 pieces - gap - 1 piece (should NOT be valid)  
    print("\nTest 2: 2-gap-2-gap-1 pattern (should be invalid)\n");
    setup_pattern_2(grid);
    test_line_detection(grid, 4, 4, "Pattern 2");
    clear_grid(grid);
    
    // Test case 3: 1 piece - gap - 2 pieces - gap - 2 pieces (should NOT be valid)
    print("\nTest 3: 1-gap-2-gap-2 pattern (should be invalid)\n");
    setup_pattern_3(grid);
    test_line_detection(grid, 4, 4, "Pattern 3");
    clear_grid(grid);
    
    // Test case 4: Valid continuous line (should be valid)
    print("\nTest 4: Continuous 5 pieces (should be valid)\n");
    setup_continuous_line(grid);
    test_line_detection(grid, 4, 4, "Continuous");
    clear_grid(grid);
}

void test_edge_cases() {
    print("\n--- Testing Edge Cases ---\n");
    
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Edge case: exactly 2 on each side with center piece
    print("Edge case: 2-center-2 pattern (should be valid)\n");
    setup_edge_case_valid(grid);
    test_line_detection(grid, 4, 4, "Edge Valid");
    clear_grid(grid);
    
    // Edge case: 1 on each side with center piece  
    print("\nEdge case: 1-center-1 pattern (should be invalid)\n");
    setup_edge_case_invalid(grid);
    test_line_detection(grid, 4, 4, "Edge Invalid");
    clear_grid(grid);
}

void setup_pattern_1(Cell[,] grid) {
    // 2 pieces - gap - 1 piece - gap - 2 pieces
    // Positions: 0,1 - gap - 3 - gap - 5,6
    place_piece(grid, 4, 0, 1); // 2 pieces
    place_piece(grid, 4, 1, 1);
    // gap at 4,2
    place_piece(grid, 4, 3, 1); // 1 piece  
    // gap at 4,4
    place_piece(grid, 4, 5, 1); // 2 pieces
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4, "Pattern 1");
}

void setup_pattern_2(Cell[,] grid) {
    // 2 pieces - gap - 2 pieces - gap - 1 piece
    place_piece(grid, 4, 0, 1); // 2 pieces
    place_piece(grid, 4, 1, 1);
    // gap at 4,2
    place_piece(grid, 4, 3, 1); // 2 pieces
    place_piece(grid, 4, 4, 1);
    // gap at 4,5
    place_piece(grid, 4, 6, 1); // 1 piece
    
    print_grid_row(grid, 4, "Pattern 2");
}

void setup_pattern_3(Cell[,] grid) {
    // 1 piece - gap - 2 pieces - gap - 2 pieces
    place_piece(grid, 4, 0, 1); // 1 piece
    // gap at 4,1
    place_piece(grid, 4, 2, 1); // 2 pieces
    place_piece(grid, 4, 3, 1);
    // gap at 4,4
    place_piece(grid, 4, 5, 1); // 2 pieces
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4, "Pattern 3");
}

void setup_continuous_line(Cell[,] grid) {
    // Continuous 5 pieces
    for (int i = 2; i <= 6; i++) {
        place_piece(grid, 4, i, 1);
    }
    
    print_grid_row(grid, 4, "Continuous");
}

void setup_edge_case_valid(Cell[,] grid) {
    // 2-center-2: exactly 5 continuous pieces
    for (int i = 2; i <= 6; i++) {
        place_piece(grid, 4, i, 1);
    }
    
    print_grid_row(grid, 4, "Edge Valid");
}

void setup_edge_case_invalid(Cell[,] grid) {
    // 1-center-1: only 3 continuous pieces
    for (int i = 3; i <= 5; i++) {
        place_piece(grid, 4, i, 1);
    }
    
    print_grid_row(grid, 4, "Edge Invalid");
}

void place_piece(Cell[,] grid, int row, int col, int piece_type) {
    grid[row, col].piece = new Piece(piece_type);
}

void clear_grid(Cell[,] grid) {
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j].piece = null;
        }
    }
}

void print_grid_row(Cell[,] grid, int row, string label) {
    print("%s: ", label);
    for (int col = 0; col < 9; col++) {
        if (grid[row, col].piece != null) {
            print("%d ", grid[row, col].piece.id);
        } else {
            print("- ");
        }
    }
    print("\n");
}

void test_line_detection(Cell[,] grid, int test_row, int test_col, string test_name) {
    var detector = new UnifiedLineDetector(grid);
    
    // Test multiple positions in the pattern
    for (int col = 0; col < 9; col++) {
        if (grid[test_row, col].piece != null) {
            var result = detector.detect_all_lines(test_row, col);
            
            print("  Position (%d,%d): ", test_row, col);
            if (result.has_any_lines()) {
                print("VALID LINE - %d cells, score %d\n", 
                      result.get_total_cells_count(), result.score_value);
            } else {
                print("No line\n");
            }
        }
    }
}

// Mock classes for testing
class Cell : Object {
    public int row { get; set; }
    public int col { get; set; }
    public Piece? piece { get; set; }
    
    public Cell(int row, int col) {
        this.row = row;
        this.col = col;
        this.piece = null;
    }
}

class Piece : Object {
    public int id { get; set; }
    
    public Piece(int id) {
        this.id = id;
    }
}

// Mock Game class
class Game {
    public static int N_MATCH = 5;
}