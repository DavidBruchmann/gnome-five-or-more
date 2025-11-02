/*
 * Test to reproduce the "two pieces on both sides" phantom line bug
 */

using Gee;

void main() {
    print("=== Two Pieces on Both Sides Bug Test ===\n");
    
    test_specific_patterns();
}

void test_specific_patterns() {
    print("\n--- Testing Specific Patterns That Cause Phantom Lines ---\n");
    
    // Create a test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Test the exact pattern you described: 2 pieces - gap - 1 piece - gap - 2 pieces
    print("Pattern A: 2-gap-1-gap-2 (user reports this creates phantom line)\n");
    setup_pattern_a(grid);
    test_with_unified_detector(grid, "Pattern A");
    clear_grid(grid);
    
    // Test variations
    print("\nPattern B: 2-gap-2-gap-1 (testing variation)\n");
    setup_pattern_b(grid);
    test_with_unified_detector(grid, "Pattern B");
    clear_grid(grid);
    
    print("\nPattern C: 1-gap-2-gap-2 (testing variation)\n");
    setup_pattern_c(grid);
    test_with_unified_detector(grid, "Pattern C");
    clear_grid(grid);
    
    // Test edge case: exactly what should be valid
    print("\nPattern D: 2-1-2 continuous (should be valid)\n");
    setup_pattern_d(grid);
    test_with_unified_detector(grid, "Pattern D");
    clear_grid(grid);
    
    // Test what should definitely be invalid
    print("\nPattern E: 1-gap-1-gap-1 (should be invalid)\n");
    setup_pattern_e(grid);
    test_with_unified_detector(grid, "Pattern E");
    clear_grid(grid);
}

void setup_pattern_a(Cell[,] grid) {
    // 2 pieces - gap - 1 piece - gap - 2 pieces
    // Positions: 0,1 - gap - 3 - gap - 5,6
    place_piece(grid, 4, 0, 1);
    place_piece(grid, 4, 1, 1);
    // gap at 2
    place_piece(grid, 4, 3, 1);
    // gap at 4
    place_piece(grid, 4, 5, 1);
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4, "2-gap-1-gap-2");
}

void setup_pattern_b(Cell[,] grid) {
    // 2 pieces - gap - 2 pieces - gap - 1 piece
    place_piece(grid, 4, 0, 1);
    place_piece(grid, 4, 1, 1);
    // gap at 2
    place_piece(grid, 4, 3, 1);
    place_piece(grid, 4, 4, 1);
    // gap at 5
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4, "2-gap-2-gap-1");
}

void setup_pattern_c(Cell[,] grid) {
    // 1 piece - gap - 2 pieces - gap - 2 pieces
    place_piece(grid, 4, 0, 1);
    // gap at 1
    place_piece(grid, 4, 2, 1);
    place_piece(grid, 4, 3, 1);
    // gap at 4
    place_piece(grid, 4, 5, 1);
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4, "1-gap-2-gap-2");
}

void setup_pattern_d(Cell[,] grid) {
    // 2-1-2 continuous (should be valid - 5 pieces total)
    for (int i = 2; i <= 6; i++) {
        place_piece(grid, 4, i, 1);
    }
    
    print_grid_row(grid, 4, "2-1-2 continuous");
}

void setup_pattern_e(Cell[,] grid) {
    // 1-gap-1-gap-1 (should definitely be invalid)
    place_piece(grid, 4, 0, 1);
    // gap at 1
    place_piece(grid, 4, 2, 1);
    // gap at 3
    place_piece(grid, 4, 4, 1);
    
    print_grid_row(grid, 4, "1-gap-1-gap-1");
}

void test_with_unified_detector(Cell[,] grid, string pattern_name) {
    print("Testing %s with UnifiedLineDetector:\n", pattern_name);
    
    // Test from each piece position
    for (int col = 0; col < 9; col++) {
        if (grid[4, col].piece != null) {
            print("  Testing from position (4, %d):\n", col);
            
            // Simulate the actual game logic path
            var cell = grid[4, col];
            var result = cell.get_all_lines_composite(grid);
            
            if (result.has_any_lines()) {
                print("    PHANTOM LINE DETECTED! ❌\n");
                print("    Traditional cells: %d\n", result.traditional_cells.size);
                print("    Composite lines: %d\n", result.composite_lines.size);
                print("    Total score: %d\n", result.total_score);
            } else {
                print("    No line detected ✅\n");
            }
        }
    }
    print("\n");
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
    print("  %s: ", label);
    for (int col = 0; col < 9; col++) {
        if (grid[row, col].piece != null) {
            print("%d ", grid[row, col].piece.id);
        } else {
            print("- ");
        }
    }
    print("\n");
}

// Mock classes that match the actual game structure
class Cell : Object {
    public int row { get; set; }
    public int col { get; set; }
    public Piece? piece { get; set; }
    
    public Cell(int row, int col) {
        this.row = row;
        this.col = col;
        this.piece = null;
    }
    
    // Mock the actual method that's called in the game
    public CompositeLineResult get_all_lines_composite(Cell[,] board) {
        var result = new CompositeLineResult();
        
        // Use unified line detector - single source of truth for all line detection
        var unified_detector = new UnifiedLineDetector(board);
        var detection_result = unified_detector.detect_all_lines(this.row, this.col);
        
        if (detection_result.has_any_lines()) {
            result.traditional_cells = detection_result.cells_to_remove;
            result.composite_lines = detection_result.visual_lines;
            result.total_score = detection_result.score_value;
        }
        
        return result;
    }
}

class Piece : Object {
    public int id { get; set; }
    
    public Piece(int id) {
        this.id = id;
    }
}

class CompositeLineResult : Object {
    public Gee.HashSet<Cell> traditional_cells { get; set; }
    public Gee.ArrayList<CompositeLine> composite_lines { get; set; }
    public int total_score { get; set; default = 0; }
    
    construct {
        traditional_cells = new Gee.HashSet<Cell>();
        composite_lines = new Gee.ArrayList<CompositeLine>();
    }
    
    public bool has_any_lines() {
        return traditional_cells.size > 0 || composite_lines.size > 0;
    }
}

// Mock Game class
class Game {
    public static int N_MATCH = 5;
}