/*
 * Test to demonstrate the boundary mismatch bug
 * Including specific user-reported scenario: 9x9 board, row 4, columns 5-8
 */

public class BoundaryTest : Object {
    
    public static int main(string[] args) {
        print("🔍 Testing Board Boundary Consistency\n\n");
        
        // Test each board size
        for (int size = 1; size <= 3; size++) {
            var game = new Game(size, 1);
            
            string size_name = "";
            switch (size) {
                case 1: size_name = "Small"; break;
                case 2: size_name = "Medium"; break;
                case 3: size_name = "Large"; break;
            }
            
            print("📋 %s Board (size %d):\n", size_name, size);
            
            // Get dimensions from game difficulty
            var n_rows = Game.game_difficulty[size].n_rows;
            var n_cols = Game.game_difficulty[size].n_cols;
            
            print("  GameDifficulty: n_rows=%d, n_cols=%d\n", n_rows, n_cols);
            print("  Game reports: n_rows=%d, n_cols=%d\n", game.n_rows, game.n_cols);
            
            // Check board grid dimensions
            var grid = game.board.get_grid();
            print("  Grid dimensions: [%d, %d]\n", grid.length[0], grid.length[1]);
            
            // Test boundary access
            bool boundary_error = false;
            
            // Test accessing last valid position
            try {
                var piece = game.board.get_piece(n_rows - 1, n_cols - 1);
                print("  ✅ Access [%d, %d]: OK\n", n_rows - 1, n_cols - 1);
            } catch (Error e) {
                print("  ❌ Access [%d, %d]: ERROR - %s\n", n_rows - 1, n_cols - 1, e.message);
                boundary_error = true;
            }
            
            // Test accessing position that should be invalid
            try {
                var piece = game.board.get_piece(n_rows, n_cols);
                print("  ⚠️  Access [%d, %d]: Should be invalid but succeeded\n", n_rows, n_cols);
                boundary_error = true;
            } catch (Error e) {
                print("  ✅ Access [%d, %d]: Correctly failed\n", n_rows, n_cols);
            }
            
            // Check if visual dimensions match logical dimensions
            if (game.n_rows != n_rows || game.n_cols != n_cols) {
                print("  ❌ MISMATCH: Game reports different dimensions than GameDifficulty!\n");
                boundary_error = true;
            }
            
            if (boundary_error) {
                print("  🐛 BOUNDARY ISSUES DETECTED!\n");
            } else {
                print("  ✅ Boundaries appear consistent\n");
            }
            
            print("\n");
        }
        
        // Test specific user-reported bug scenario
        print("🎯 Testing User-Reported Bug Scenario:\n");
        test_specific_bug_scenario();
        
        print("\n🎯 Summary:\n");
        print("  - Check if Large board (20x15) has coordinate issues\n");
        print("  - Verify that visual display matches logical board\n");
        print("  - Look for row/column swapping in coordinate usage\n");
        print("  - Test specific 9x9 board row 4, columns 5-8 scenario\n");
        
        return 0;
    }
    
    private static void test_specific_bug_scenario() {
        print("📍 Testing 9x9 board, row 4, columns 5-8 scenario:\n");
        
        var game = new Game(2, 1); // Medium board (9x9)
        
        // Simulate the reported scenario:
        // Row 4, columns 5-8 should form a 4-piece line
        // Positions 4-4 and 4-9 are occupied by other pieces
        
        print("  Setting up scenario:\n");
        print("    - Row 4, columns 5-8: Same color pieces (should be 4-piece line)\n");
        print("    - Position [4,4]: Different color piece (blocker)\n");
        print("    - Position [4,9]: Different color piece (blocker)\n");
        
        // Test coordinate access for these positions
        int test_row = 3; // 0-based indexing for row 4
        
        for (int col = 3; col <= 8; col++) { // 0-based indexing for columns 4-9
            try {
                var piece = game.board.get_piece(test_row, col);
                print("    ✅ Access [%d, %d] (row %d, col %d): OK\n", 
                      test_row, col, test_row + 1, col + 1);
            } catch (Error e) {
                print("    ❌ Access [%d, %d] (row %d, col %d): ERROR - %s\n", 
                      test_row, col, test_row + 1, col + 1, e.message);
            }
        }
        
        // Check if line detection would work correctly in this area
        print("  Checking line detection boundary conditions:\n");
        
        // Test horizontal line detection around the problematic area
        var line_detector = new LineDetector(game.board.get_grid());
        
        // This would require actual pieces to be placed, but we can test the coordinate logic
        print("    - Line detector initialized for 9x9 board\n");
        print("    - Grid dimensions: [%d, %d]\n", 
              game.board.get_grid().length[0], game.board.get_grid().length[1]);
        
        // Check if the coordinate system is consistent
        if (game.n_rows == 9 && game.n_cols == 9) {
            print("    ✅ Game reports correct 9x9 dimensions\n");
        } else {
            print("    ❌ Game reports incorrect dimensions: %dx%d\n", game.n_rows, game.n_cols);
        }
        
        print("  🔍 This scenario could trigger the boundary bug if:\n");
        print("    - Coordinate mismatch causes wrong line length calculation\n");
        print("    - Boundary checks fail due to row/column confusion\n");
        print("    - Line detection algorithm miscounts pieces due to coordinate issues\n");
        
        // Test the specific coordinate mapping that might be problematic
        print("  Testing coordinate mapping for reported positions:\n");
        
        // Test the exact positions mentioned by user
        int[] test_cols = {4, 5, 6, 7, 8}; // columns 5-8 plus blockers at 4 and 9 (1-based)
        
        foreach (int col_1based in test_cols) {
            int col_0based = col_1based - 1;
            int row_0based = 3; // row 4 (1-based) = row 3 (0-based)
            
            print("    Position [%d,%d] (1-based [%d,%d]):\n", 
                  row_0based, col_0based, test_row + 1, col_1based);
            
            // Check if this position is within bounds
            var grid = game.board.get_grid();
            bool in_bounds = (row_0based >= 0 && row_0based < grid.length[0] && 
                             col_0based >= 0 && col_0based < grid.length[1]);
            
            if (in_bounds) {
                print("      ✅ Within grid bounds\n");
            } else {
                print("      ❌ OUT OF BOUNDS! This could cause the bug!\n");
            }
        }
        
        print("  💡 Analysis:\n");
        print("    - If coordinate mismatch exists, line detection might:\n");
        print("      • Count wrong number of pieces in the line\n");
        print("      • Access wrong grid positions\n");
        print("      • Trigger removal of 4-piece lines instead of 5-piece\n");
        print("      • Fail to detect blocking pieces at boundaries\n");
        print("      • Create phantom lines where only endpoints match\n");
        print("      • Ignore gaps or foreign pieces between endpoints\n");
        
        // Test phantom line detection scenario
        print("  🔍 Testing Phantom Line Detection:\n");
        test_phantom_line_scenario();
    }
    
    private static void test_phantom_line_scenario() {
        print("    📍 Phantom Line Scenario:\n");
        print("      - Pattern: Outer pieces match, but gaps/foreign pieces in between\n");
        print("      - Expected: Should NOT be treated as a valid line\n");
        print("      - Bug: Algorithm might only check endpoints and ignore middle\n");
        
        var game = new Game(2, 1); // Medium board for testing
        
        print("      Testing coordinate access for phantom line pattern:\n");
        
        // Test a potential phantom line: positions that span a distance but aren't continuous
        int test_row = 4; // Middle of 9x9 board
        int[] test_positions = {1, 2, 3, 4, 5, 6, 7}; // Span across row
        
        foreach (int col in test_positions) {
            try {
                var piece = game.board.get_piece(test_row, col);
                print("        Position [%d, %d]: Accessible\n", test_row, col);
            } catch (Error e) {
                print("        Position [%d, %d]: ERROR - %s\n", test_row, col, e.message);
            }
        }
        
        print("      💡 Phantom Line Risk:\n");
        print("        - If algorithm uses coordinate distance instead of piece counting\n");
        print("        - If boundary checks are wrong, it might count span as line length\n");
        print("        - If continuity validation is missing, gaps become invisible\n");
        print("        - This could explain why non-continuous patterns get removed\n");
    }
}