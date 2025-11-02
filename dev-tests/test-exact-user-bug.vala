/*
 * Test to reproduce the exact user-reported bug:
 * 6 pieces with one foreign color in between that gets removed
 */

using Gee;

void main() {
    print("=== Exact User Bug Reproduction ===\n");
    
    test_user_reported_pattern();
}

void test_user_reported_pattern() {
    print("User reported: 6 pieces with one foreign color in between gets removed\n");
    print("Pattern: XXX-Y-XXX (3 red, 1 blue, 3 red)\n");
    print("This should NOT be removed!\n\n");
    
    // Create test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Set up the exact pattern: 3 red - 1 blue - 3 red
    place_piece(grid, 4, 1, 1); // Red
    place_piece(grid, 4, 2, 1); // Red  
    place_piece(grid, 4, 3, 1); // Red
    place_piece(grid, 4, 4, 2); // Blue (foreign)
    place_piece(grid, 4, 5, 1); // Red
    place_piece(grid, 4, 6, 1); // Red
    place_piece(grid, 4, 7, 1); // Red
    
    print_grid_row(grid, 4, "User pattern");
    
    // Test the exact logic from detect_traditional_lines
    print("Testing detect_traditional_lines logic:\n");
    test_detect_traditional_lines_logic(grid, 4, 4); // Test from the foreign piece
    
    print("\nTesting from each red piece:\n");
    for (int col = 1; col <= 7; col++) {
        if (col != 4 && grid[4, col].piece != null) { // Skip the foreign piece
            print("From position (4,%d):\n", col);
            test_detect_traditional_lines_logic(grid, 4, col);
        }
    }
}

void test_detect_traditional_lines_logic(Cell[,] grid, int row, int col) {
    var cell = grid[row, col];
    if (cell.piece == null) {
        print("  No piece at position\n");
        return;
    }
    
    print("  Piece type: %d\n", cell.piece.id);
    
    var all_cells = new HashSet<Cell>();
    
    // Check all four directions (exactly like detect_traditional_lines)
    var horizontal_cells = get_bidirectional_line(grid, row, col, 0, 1, cell.piece.id);
    var vertical_cells = get_bidirectional_line(grid, row, col, 1, 0, cell.piece.id);
    var diagonal1_cells = get_bidirectional_line(grid, row, col, 1, 1, cell.piece.id);
    var diagonal2_cells = get_bidirectional_line(grid, row, col, 1, -1, cell.piece.id);
    
    print("  Horizontal: %d pieces\n", horizontal_cells.size);
    print("  Vertical: %d pieces\n", vertical_cells.size);
    print("  Diagonal1: %d pieces\n", diagonal1_cells.size);
    print("  Diagonal2: %d pieces\n", diagonal2_cells.size);
    
    // Add lines that meet the minimum length requirement (N_MATCH = 5)
    if (horizontal_cells.size >= 5) {
        print("  ❌ ADDING HORIZONTAL LINE!\n");
        all_cells.add_all(horizontal_cells);
    }
    
    if (vertical_cells.size >= 5) {
        print("  ❌ ADDING VERTICAL LINE!\n");
        all_cells.add_all(vertical_cells);
    }
    
    if (diagonal1_cells.size >= 5) {
        print("  ❌ ADDING DIAGONAL1 LINE!\n");
        all_cells.add_all(diagonal1_cells);
    }
    
    if (diagonal2_cells.size >= 5) {
        print("  ❌ ADDING DIAGONAL2 LINE!\n");
        all_cells.add_all(diagonal2_cells);
    }
    
    print("  Total cells to remove: %d\n", all_cells.size);
    if (all_cells.size > 0) {
        print("  ❌ BUG DETECTED! This should be 0!\n");
        print("  Cells: ");
        foreach (var c in all_cells) {
            print("(%d,%d) ", c.row, c.col);
        }
        print("\n");
    } else {
        print("  ✅ Correct - no phantom line\n");
    }
    print("\n");
}

HashSet<Cell> get_bidirectional_line(Cell[,] grid, int start_row, int start_col, int dr, int dc, int piece_type) {
    var line_cells = new HashSet<Cell>();
    
    // Add the starting cell
    line_cells.add(grid[start_row, start_col]);
    
    // Scan in positive direction (excluding starting cell)
    int row = start_row + dr;
    int col = start_col + dc;
    while (row >= 0 && row < 9 && col >= 0 && col < 9) {
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
    while (row >= 0 && row < 9 && col >= 0 && col < 9) {
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

void place_piece(Cell[,] grid, int row, int col, int piece_type) {
    grid[row, col].piece = new Piece(piece_type);
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
    print("\n\n");
}

// Mock classes
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