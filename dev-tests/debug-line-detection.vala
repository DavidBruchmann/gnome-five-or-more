/*
 * Debug script to test line detection logic
 */

using Gtk;

public class LineDetectionDebug : Object {
    
    public static int main(string[] args) {
        print("🔍 Debugging Line Detection Logic...\n");
        
        // Create a test game
        var game = new Game(2, 1); // Medium board, normal difficulty
        
        // Test the constants
        print("Game constants:\n");
        print("  N_MATCH = %d\n", Game.N_MATCH);
        print("  N_TYPES = %d\n", Game.N_TYPES);
        
        // Create a test scenario with exactly 4 pieces in a row
        print("\n🧪 Testing 4-piece line detection...\n");
        
        // Clear the board first
        for (int row = 0; row < game.n_rows; row++) {
            for (int col = 0; col < game.n_cols; col++) {
                game.board.set_piece(row, col, null);
            }
        }
        
        // Place exactly 4 pieces of the same type in a horizontal line
        var test_piece = new Piece(0); // Type 0
        game.board.set_piece(2, 2, test_piece);
        game.board.set_piece(2, 3, new Piece(0));
        game.board.set_piece(2, 4, new Piece(0));
        game.board.set_piece(2, 5, new Piece(0));
        
        print("Placed 4 pieces of type 0 at positions: (2,2), (2,3), (2,4), (2,5)\n");
        
        // Test line detection on the middle piece
        var test_cell = game.board.get_cell(2, 3);
        var line_result = test_cell.get_all_lines_composite(game.board.get_grid());
        
        print("Line detection results:\n");
        print("  has_traditional_lines: %s\n", line_result.has_traditional_lines ? "true" : "false");
        print("  has_composite_lines: %s\n", line_result.has_composite_lines ? "true" : "false");
        print("  has_any_lines: %s\n", line_result.has_any_lines() ? "true" : "false");
        
        if (line_result.has_traditional_lines) {
            print("  traditional_cells count: %d\n", line_result.traditional_cells.size);
        }
        
        if (line_result.has_composite_lines) {
            print("  composite_lines count: %d\n", line_result.composite_lines.size);
            foreach (var line in line_result.composite_lines) {
                print("    - Line total_length: %d\n", line.total_length);
            }
        }
        
        // Test with exactly 5 pieces
        print("\n🧪 Testing 5-piece line detection...\n");
        game.board.set_piece(2, 6, new Piece(0)); // Add 5th piece
        
        line_result = test_cell.get_all_lines_composite(game.board.get_grid());
        
        print("Line detection results (5 pieces):\n");
        print("  has_traditional_lines: %s\n", line_result.has_traditional_lines ? "true" : "false");
        print("  has_composite_lines: %s\n", line_result.has_composite_lines ? "true" : "false");
        print("  has_any_lines: %s\n", line_result.has_any_lines() ? "true" : "false");
        
        if (line_result.has_traditional_lines) {
            print("  traditional_cells count: %d\n", line_result.traditional_cells.size);
        }
        
        if (line_result.has_composite_lines) {
            print("  composite_lines count: %d\n", line_result.composite_lines.size);
            foreach (var line in line_result.composite_lines) {
                print("    - Line total_length: %d\n", line.total_length);
            }
        }
        
        print("\n✅ Debug complete!\n");
        
        return 0;
    }
}