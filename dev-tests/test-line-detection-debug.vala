/*
 * Debug line detection behavior
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

// Mock game constants
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
    internal int N_MATCH { get; private set; default = 5; }
    
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

// Mock Game class
internal class Game : Object {
    internal static int N_MATCH { get { return get_game_constants().N_MATCH; } }
}

// Mock Piece class
internal class Piece : Object {
    public int id { get; set; }
    
    public Piece(int id) {
        this.id = id;
    }
    
    public bool equal(Piece other) {
        return this.id == other.id;
    }
}

// Mock Cell class
internal class Cell : Object {
    public int row { get; set; }
    public int col { get; set; }
    public Piece? piece { get; set; }
    
    public Cell(int row, int col) {
        this.row = row;
        this.col = col;
        this.piece = null;
    }
}

int main(string[] args) {
    print("Testing Line Detection Logic\n");
    print("===========================\n\n");
    
    // Create a simple 9x9 grid
    var grid = new Cell[9, 9];
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            grid[r, c] = new Cell(r, c);
        }
    }
    
    // Test scenario: 3 pieces + gap + 2 pieces
    print("Test scenario: 3 pieces + gap + 2 pieces\n");
    print("Row 4: [Red][Red][Red][Empty][Red][Red]\n");
    print("       Col 0  Col 1  Col 2  Col 3   Col 4  Col 5\n\n");
    
    // Place pieces
    grid[4, 0].piece = new Piece(1); // Red
    grid[4, 1].piece = new Piece(1); // Red  
    grid[4, 2].piece = new Piece(1); // Red
    // grid[4, 3] is empty
    grid[4, 4].piece = new Piece(1); // Red
    grid[4, 5].piece = new Piece(1); // Red
    
    print("Current N_MATCH requirement: %d pieces\n", Game.N_MATCH);
    print("Total Red pieces in row: 5\n");
    print("But they are NOT continuous (gap at col 3)\n\n");
    
    print("Expected behavior: NO line should be detected\n");
    print("Actual behavior: Let's test...\n\n");
    
    // Test the line detection logic manually
    print("Manual test of continuity:\n");
    
    // Check left direction from position (4,2)
    int continuous_left = 0;
    for (int c = 2; c >= 0; c--) {
        if (grid[4, c].piece != null && grid[4, c].piece.id == 1) {
            continuous_left++;
        } else {
            break;
        }
    }
    
    // Check right direction from position (4,2)  
    int continuous_right = 0;
    for (int c = 3; c < 9; c++) {
        if (grid[4, c].piece != null && grid[4, c].piece.id == 1) {
            continuous_right++;
        } else {
            break;
        }
    }
    
    print("From position (4,2):\n");
    print("- Continuous left (including self): %d pieces\n", continuous_left);
    print("- Continuous right: %d pieces\n", continuous_right);
    print("- Total continuous: %d pieces\n", continuous_left + continuous_right);
    print("- Should be valid: %s\n\n", (continuous_left + continuous_right >= Game.N_MATCH) ? "YES" : "NO");
    
    // The issue might be that we're checking from the wrong position
    // Let's check from position (4,4) where there are pieces on both sides
    print("From position (4,4):\n");
    
    continuous_left = 0;
    for (int c = 4; c >= 0; c--) {
        if (grid[4, c].piece != null && grid[4, c].piece.id == 1) {
            continuous_left++;
        } else {
            break;
        }
    }
    
    continuous_right = 0;
    for (int c = 5; c < 9; c++) {
        if (grid[4, c].piece != null && grid[4, c].piece.id == 1) {
            continuous_right++;
        } else {
            break;
        }
    }
    
    print("- Continuous left (including self): %d pieces\n", continuous_left);
    print("- Continuous right: %d pieces\n", continuous_right);
    print("- Total continuous: %d pieces\n", continuous_left + continuous_right);
    print("- Should be valid: %s\n\n", (continuous_left + continuous_right >= Game.N_MATCH) ? "YES" : "NO");
    
    print("The problem might be in how we combine left and right directions!\n");
    
    return 0;
}