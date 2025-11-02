/*
 * Simple test to investigate the bidirectional line bug
 */

using Gee;

void main() {
    print("=== Simple Bidirectional Line Bug Test ===\n");
    
    test_bidirectional_logic();
}

void test_bidirectional_logic() {
    print("\n--- Testing Bidirectional Scanning Logic ---\n");
    
    // Create a test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Test the specific pattern that causes phantom lines
    print("Testing pattern: 2 pieces - gap - 1 piece - gap - 2 pieces\n");
    
    // Place pieces: positions 0,1 - gap - 3 - gap - 5,6
    place_piece(grid, 4, 0, 1);
    place_piece(grid, 4, 1, 1);
    // gap at position 2
    place_piece(grid, 4, 3, 1);
    // gap at position 4  
    place_piece(grid, 4, 5, 1);
    place_piece(grid, 4, 6, 1);
    
    print_grid_row(grid, 4);
    
    // Test bidirectional scanning from the center piece (position 3)
    print("\nTesting from center piece at (4,3):\n");
    test_bidirectional_scan(grid, 4, 3);
    
    // Test from other positions
    print("\nTesting from position (4,1):\n");
    test_bidirectional_scan(grid, 4, 1);
    
    print("\nTesting from position (4,5):\n");
    test_bidirectional_scan(grid, 4, 5);
}

void test_bidirectional_scan(Cell[,] grid, int start_row, int start_col) {
    var piece = grid[start_row, start_col].piece;
    if (piece == null) {
        print("No piece at position (%d, %d)\n", start_row, start_col);
        return;
    }
    
    print("Piece type: %d\n", piece.id);
    
    // Manual bidirectional scan (horizontal)
    var line_cells = new HashSet<Cell>();
    
    // Add the starting cell
    line_cells.add(grid[start_row, start_col]);
    print("Added center cell (%d, %d)\n", start_row, start_col);
    
    // Scan right (positive direction)
    int col = start_col + 1;
    print("Scanning right from (%d, %d):\n", start_row, col);
    while (col < 9) {
        var cell = grid[start_row, col];
        if (cell.piece == null || cell.piece.id != piece.id) {
            print("  (%d, %d): %s - STOP\n", start_row, col, 
                  cell.piece == null ? "empty" : "different piece");
            break;
        }
        line_cells.add(cell);
        print("  (%d, %d): match - CONTINUE\n", start_row, col);
        col++;
    }
    
    // Scan left (negative direction)
    col = start_col - 1;
    print("Scanning left from (%d, %d):\n", start_row, col);
    while (col >= 0) {
        var cell = grid[start_row, col];
        if (cell.piece == null || cell.piece.id != piece.id) {
            print("  (%d, %d): %s - STOP\n", start_row, col,
                  cell.piece == null ? "empty" : "different piece");
            break;
        }
        line_cells.add(cell);
        print("  (%d, %d): match - CONTINUE\n", start_row, col);
        col--;
    }
    
    print("Total continuous pieces found: %d\n", line_cells.size);
    print("Required for valid line: 5\n");
    print("Result: %s\n", line_cells.size >= 5 ? "VALID LINE" : "No line");
    
    // Print all cells in the line
    print("Line cells: ");
    foreach (var cell in line_cells) {
        print("(%d,%d) ", cell.row, cell.col);
    }
    print("\n");
}

void place_piece(Cell[,] grid, int row, int col, int piece_type) {
    grid[row, col].piece = new Piece(piece_type);
}

void print_grid_row(Cell[,] grid, int row) {
    print("Row %d: ", row);
    for (int col = 0; col < 9; col++) {
        if (grid[row, col].piece != null) {
            print("%d ", grid[row, col].piece.id);
        } else {
            print("- ");
        }
    }
    print("\n");
}

// Simple mock classes
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