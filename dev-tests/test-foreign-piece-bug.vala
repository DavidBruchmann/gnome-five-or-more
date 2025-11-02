/*
 * Test to reproduce the foreign piece phantom line bug
 * Pattern: 3 pieces - 1 foreign piece - 3 pieces (should NOT be removed)
 */

using Gee;

void main() {
    print("=== Foreign Piece Phantom Line Bug Test ===\n");
    
    test_foreign_piece_pattern();
}

void test_foreign_piece_pattern() {
    print("Testing pattern: XXX-Y-XXX (where Y is foreign color)\n");
    print("This should NOT be removed, but user reports it is!\n\n");
    
    // Create test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Set up the pattern: 3 red pieces - 1 blue piece - 3 red pieces
    // Positions: 0,1,2 - 3 - 4,5,6
    place_piece(grid, 4, 0, 1); // Red
    place_piece(grid, 4, 1, 1); // Red  
    place_piece(grid, 4, 2, 1); // Red
    place_piece(grid, 4, 3, 2); // Blue (foreign)
    place_piece(grid, 4, 4, 1); // Red
    place_piece(grid, 4, 5, 1); // Red
    place_piece(grid, 4, 6, 1); // Red
    
    print_grid_row(grid, 4, "XXX-Y-XXX");
    
    // Test bidirectional scanning manually
    print("\nTesting bidirectional scanning from each position:\n");
    
    for (int col = 0; col < 7; col++) {
        if (grid[4, col].piece != null) {
            print("Position (4,%d) - piece type %d:\n", col, grid[4, col].piece.id);
            test_bidirectional_manual(grid, 4, col);
            print("\n");
        }
    }
}

void test_bidirectional_manual(Cell[,] grid, int start_row, int start_col) {
    var piece = grid[start_row, start_col].piece;
    var line_cells = new HashSet<Cell>();
    
    // Add starting cell
    line_cells.add(grid[start_row, start_col]);
    print("  Added center: (%d,%d)\n", start_row, start_col);
    
    // Scan right
    int col = start_col + 1;
    print("  Scanning right:\n");
    while (col < 9) {
        var cell = grid[start_row, col];
        if (cell.piece == null) {
            print("    (%d,%d): empty - STOP\n", start_row, col);
            break;
        }
        if (cell.piece.id != piece.id) {
            print("    (%d,%d): foreign piece (type %d) - STOP\n", start_row, col, cell.piece.id);
            break;
        }
        line_cells.add(cell);
        print("    (%d,%d): match - CONTINUE\n", start_row, col);
        col++;
    }
    
    // Scan left
    col = start_col - 1;
    print("  Scanning left:\n");
    while (col >= 0) {
        var cell = grid[start_row, col];
        if (cell.piece == null) {
            print("    (%d,%d): empty - STOP\n", start_row, col);
            break;
        }
        if (cell.piece.id != piece.id) {
            print("    (%d,%d): foreign piece (type %d) - STOP\n", start_row, col, cell.piece.id);
            break;
        }
        line_cells.add(cell);
        print("    (%d,%d): match - CONTINUE\n", start_row, col);
        col--;
    }
    
    print("  Total continuous pieces: %d\n", line_cells.size);
    print("  Required for line: 5\n");
    print("  Result: %s\n", line_cells.size >= 5 ? "VALID LINE (BUG!)" : "No line (correct)");
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
    print("\n");
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