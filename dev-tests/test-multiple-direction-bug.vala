/*
 * Test to check if the bug is in combining multiple directions
 */

using Gee;

void main() {
    print("=== Multiple Direction Bug Test ===\n");
    
    test_cross_pattern();
}

void test_cross_pattern() {
    print("Testing cross pattern that might trigger multiple direction bug:\n");
    print("    X\n");
    print("    X\n");
    print("XXXXX\n");
    print("    X\n");
    print("    X\n\n");
    
    // Create test grid
    var grid = new Cell[9, 9];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            grid[i, j] = new Cell(i, j);
        }
    }
    
    // Set up cross pattern centered at (4,4)
    // Horizontal line: (4,2), (4,3), (4,4), (4,5), (4,6)
    place_piece(grid, 4, 2, 1);
    place_piece(grid, 4, 3, 1);
    place_piece(grid, 4, 4, 1);
    place_piece(grid, 4, 5, 1);
    place_piece(grid, 4, 6, 1);
    
    // Vertical line: (2,4), (3,4), (4,4), (5,4), (6,4)
    place_piece(grid, 2, 4, 1);
    place_piece(grid, 3, 4, 1);
    // (4,4) already placed
    place_piece(grid, 5, 4, 1);
    place_piece(grid, 6, 4, 1);
    
    print_grid(grid);
    
    // Test each direction separately
    print("Testing horizontal direction from (4,4):\n");
    test_direction(grid, 4, 4, 0, 1, "horizontal");
    
    print("\nTesting vertical direction from (4,4):\n");
    test_direction(grid, 4, 4, 1, 0, "vertical");
    
    print("\nTesting diagonal1 direction from (4,4):\n");
    test_direction(grid, 4, 4, 1, 1, "diagonal1");
    
    print("\nTesting diagonal2 direction from (4,4):\n");
    test_direction(grid, 4, 4, 1, -1, "diagonal2");
    
    // Now test what happens when we combine all directions
    print("\nCombining all directions (this is what detect_traditional_lines does):\n");
    test_combined_directions(grid, 4, 4);
}

void test_direction(Cell[,] grid, int start_row, int start_col, int dr, int dc, string direction_name) {
    var line_cells = new HashSet<Cell>();
    var piece = grid[start_row, start_col].piece;
    
    // Add starting cell
    line_cells.add(grid[start_row, start_col]);
    
    // Scan positive direction
    int row = start_row + dr;
    int col = start_col + dc;
    while (row >= 0 && row < 9 && col >= 0 && col < 9) {
        var cell = grid[row, col];
        if (cell.piece == null || cell.piece.id != piece.id) {
            break;
        }
        line_cells.add(cell);
        row += dr;
        col += dc;
    }
    
    // Scan negative direction
    row = start_row - dr;
    col = start_col - dc;
    while (row >= 0 && row < 9 && col >= 0 && col < 9) {
        var cell = grid[row, col];
        if (cell.piece == null || cell.piece.id != piece.id) {
            break;
        }
        line_cells.add(cell);
        row -= dr;
        col -= dc;
    }
    
    print("  %s: %d pieces", direction_name, line_cells.size);
    if (line_cells.size >= 5) {
        print(" -> VALID LINE");
    }
    print("\n");
    
    print("  Cells: ");
    foreach (var cell in line_cells) {
        print("(%d,%d) ", cell.row, cell.col);
    }
    print("\n");
}

void test_combined_directions(Cell[,] grid, int start_row, int start_col) {
    var all_cells = new HashSet<Cell>();
    var piece = grid[start_row, start_col].piece;
    
    // Test each direction and add valid lines
    var directions = new int[,] {{0,1}, {1,0}, {1,1}, {1,-1}};
    string[] direction_names = {"horizontal", "vertical", "diagonal1", "diagonal2"};
    
    for (int i = 0; i < 4; i++) {
        var line_cells = new HashSet<Cell>();
        int dr = directions[i,0];
        int dc = directions[i,1];
        
        // Add starting cell
        line_cells.add(grid[start_row, start_col]);
        
        // Scan positive direction
        int row = start_row + dr;
        int col = start_col + dc;
        while (row >= 0 && row < 9 && col >= 0 && col < 9) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece.id) {
                break;
            }
            line_cells.add(cell);
            row += dr;
            col += dc;
        }
        
        // Scan negative direction
        row = start_row - dr;
        col = start_col - dc;
        while (row >= 0 && row < 9 && col >= 0 && col < 9) {
            var cell = grid[row, col];
            if (cell.piece == null || cell.piece.id != piece.id) {
                break;
            }
            line_cells.add(cell);
            row -= dr;
            col -= dc;
        }
        
        if (line_cells.size >= 5) {
            print("  Adding %s line (%d pieces)\n", direction_names[i], line_cells.size);
            all_cells.add_all(line_cells);
        }
    }
    
    print("  Total cells to remove: %d\n", all_cells.size);
    print("  Cells: ");
    foreach (var cell in all_cells) {
        print("(%d,%d) ", cell.row, cell.col);
    }
    print("\n");
}

void place_piece(Cell[,] grid, int row, int col, int piece_type) {
    grid[row, col].piece = new Piece(piece_type);
}

void print_grid(Cell[,] grid) {
    print("Grid:\n");
    for (int row = 0; row < 9; row++) {
        print("  ");
        for (int col = 0; col < 9; col++) {
            if (grid[row, col].piece != null) {
                print("%d ", grid[row, col].piece.id);
            } else {
                print("- ");
            }
        }
        print("\n");
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