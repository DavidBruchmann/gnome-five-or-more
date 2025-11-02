/*
 * Test script to verify line detection logic
 * This will help identify if there are issues with the core algorithm
 */

using Gtk;

void test_line_detection_constants() {
    print("Testing Line Detection Constants\n");
    print("===============================\n");
    
    // Test the configurable constants
    var constants = get_game_constants();
    print("N_MATCH (pieces needed for line): %d\n", constants.N_MATCH);
    print("N_TYPES (piece types): %d\n", constants.N_TYPES);
    print("N_ANIMATIONS: %d\n", constants.N_ANIMATIONS);
    
    // Test board sizes
    print("\nBoard Configurations:\n");
    var difficulties = constants.game_difficulty;
    for (int i = 1; i < difficulties.length; i++) {
        var diff = difficulties[i];
        print("Size %d: %dx%d board, %d types, %d next pieces\n", 
              i, diff.n_cols, diff.n_rows, diff.n_types, diff.n_next_pieces);
    }
    
    print("\nPotential Issues to Check:\n");
    print("1. Is N_MATCH being used consistently everywhere?\n");
    print("2. Are boundary checks correct in get_neighbour()?\n");
    print("3. Is the coordinate system (row,col) vs (x,y) consistent?\n");
    print("4. Are the board dimensions matching the grid dimensions?\n");
    
    print("\nTo test line detection:\n");
    print("1. Run the game with debug panel enabled\n");
    print("2. Create a line of exactly %d pieces\n", constants.N_MATCH);
    print("3. Check if it gets detected correctly\n");
    print("4. Try lines at board edges and corners\n");
}

int main(string[] args) {
    test_line_detection_constants();
    return 0;
}