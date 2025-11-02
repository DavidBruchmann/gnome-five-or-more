/*
 * Direct test of the phantom line bug using actual game logic
 */

void main() {
    print("=== Direct Phantom Line Bug Test ===\n");
    
    // Test by running the actual game and checking line detection
    test_actual_game_behavior();
}

void test_actual_game_behavior() {
    print("Testing with actual Five or More game...\n");
    
    // Create a game instance
    var game = new Game();
    
    // Set up the problematic pattern on the board
    // Pattern: 2 pieces - gap - 1 piece - gap - 2 pieces
    print("Setting up pattern: 2-gap-1-gap-2\n");
    
    // Place pieces at positions (4,0), (4,1), (4,3), (4,5), (4,6)
    game.board.set_piece(4, 0, new Piece(1));
    game.board.set_piece(4, 1, new Piece(1));
    // gap at (4,2)
    game.board.set_piece(4, 3, new Piece(1));
    // gap at (4,4)
    game.board.set_piece(4, 5, new Piece(1));
    game.board.set_piece(4, 6, new Piece(1));
    
    // Print the board state
    print("Board state:\n");
    print_board_row(game.board, 4);
    
    // Test line detection from each piece position
    print("\nTesting line detection from each piece:\n");
    
    test_position(game.board, 4, 0, "Position (4,0)");
    test_position(game.board, 4, 1, "Position (4,1)");
    test_position(game.board, 4, 3, "Position (4,3)");
    test_position(game.board, 4, 5, "Position (4,5)");
    test_position(game.board, 4, 6, "Position (4,6)");
    
    // Test what happens when we try to place a piece and trigger line detection
    print("\nSimulating piece placement and line detection:\n");
    simulate_piece_placement(game, 4, 3);
}

void test_position(Board board, int row, int col, string label) {
    print("  %s:\n", label);
    
    var cell = board.get_cell(row, col);
    var result = cell.get_all_lines_composite(board.get_grid());
    
    if (result.has_any_lines()) {
        print("    ❌ PHANTOM LINE DETECTED!\n");
        print("    Traditional cells: %d\n", result.traditional_cells.size);
        print("    Composite lines: %d\n", result.composite_lines.size);
        print("    Total score: %d\n", result.total_score);
        
        // Print which cells would be removed
        print("    Cells to remove: ");
        foreach (var cell_to_remove in result.traditional_cells) {
            print("(%d,%d) ", cell_to_remove.row, cell_to_remove.col);
        }
        print("\n");
    } else {
        print("    ✅ No line detected (correct)\n");
    }
}

void simulate_piece_placement(Game game, int row, int col) {
    print("Simulating placement at (%d, %d):\n", row, col);
    
    var cell = game.board.get_cell(row, col);
    var result = cell.get_all_lines_composite(game.board.get_grid());
    
    if (result.has_any_lines()) {
        print("  Game would remove %d pieces and award %d points\n", 
              result.traditional_cells.size, result.total_score);
        print("  This is the PHANTOM LINE BUG!\n");
    } else {
        print("  No lines detected - game behavior is correct\n");
    }
}

void print_board_row(Board board, int row) {
    print("  Row %d: ", row);
    for (int col = 0; col < board.get_n_cols(); col++) {
        var cell = board.get_cell(row, col);
        if (cell.piece != null) {
            print("%d ", cell.piece.id);
        } else {
            print("- ");
        }
    }
    print("\n");
}