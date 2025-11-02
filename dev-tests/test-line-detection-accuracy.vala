/*
 * Line Detection Accuracy Test Suite
 * Tests the fundamental line detection logic that feeds into scoring
 */

using GLib;

public class LineDetectionAccuracyTest : Object {
    
    private enum PieceType {
        EMPTY = 0,
        RED = 1,
        BLUE = 2,
        GREEN = 3,
        YELLOW = 4
    }
    
    public static int main(string[] args) {
        var test = new LineDetectionAccuracyTest();
        test.run_line_detection_tests();
        return 0;
    }
    
    private void run_line_detection_tests() {
        print("=== Line Detection Accuracy Test Suite ===\n\n");
        print("Testing the ROOT CAUSE: Line detection boundary bugs\n");
        print("Scoring is calculated correctly - the issue is WHICH pieces are detected!\n\n");
        
        // Test the reported boundary bug scenarios
        test_four_piece_line_bug();
        test_phantom_line_detection();
        test_interrupted_line_detection();
        test_boundary_edge_cases();
        test_large_board_coordinate_issues();
        
        print("\n=== Line Detection Testing Complete ===\n");
    }
    
    private void test_four_piece_line_bug() {
        print("Testing 4-Piece Line Bug (User Report: 9x9 board, row 4, cols 5-8):\n");
        print("EXPECTED: 4-piece lines should NOT be detected as valid\n");
        print("ACTUAL BUG: 4-piece lines are being removed incorrectly\n\n");
        
        // Simulate the reported scenario
        var board = create_test_board(9, 9);
        
        // Place 4 red pieces in row 4, columns 5-8 (0-indexed: row 3, cols 4-7)
        board[3, 4] = PieceType.RED;
        board[3, 5] = PieceType.RED;
        board[3, 6] = PieceType.RED;
        board[3, 7] = PieceType.RED;
        
        print("  Test board setup (9x9):\n");
        print("    Row 4, Cols 5-8: [RED, RED, RED, RED] (4 pieces)\n");
        
        // Test line detection
        var detected_line = detect_horizontal_line(board, 3, 4, PieceType.RED);
        
        print("  Line detection result:\n");
        print("    Detected length: %d pieces\n", detected_line.length);
        print("    Should be valid (≥5): %s\n", detected_line.length >= 5 ? "YES" : "NO");
        print("    Current behavior: %s\n", detected_line.is_valid ? "REMOVES LINE" : "IGNORES LINE");
        
        if (detected_line.length == 4 && detected_line.is_valid) {
            print("    🐛 BUG CONFIRMED: 4-piece line incorrectly detected as valid!\n");
        } else if (detected_line.length == 4 && !detected_line.is_valid) {
            print("    ✅ CORRECT: 4-piece line properly ignored\n");
        } else {
            print("    ❓ UNEXPECTED: Line length = %d\n", detected_line.length);
        }
        
        print("\n");
    }
    
    private void test_phantom_line_detection() {
        print("Testing Phantom Line Detection:\n");
        print("EXPECTED: Lines with gaps should NOT be detected\n");
        print("BUG: Only checking endpoints, ignoring intermediate pieces\n\n");
        
        var board = create_test_board(9, 9);
        
        // Create phantom line: RED at positions 0,2,4 and BLUE at positions 1,3
        // Pattern: [RED, BLUE, RED, BLUE, RED] - should NOT be a valid red line
        board[4, 0] = PieceType.RED;   // Start
        board[4, 1] = PieceType.BLUE;  // Gap
        board[4, 2] = PieceType.RED;   // Middle
        board[4, 3] = PieceType.BLUE;  // Gap  
        board[4, 4] = PieceType.RED;   // End
        
        print("  Test board setup:\n");
        print("    Row 5: [RED, BLUE, RED, BLUE, RED]\n");
        print("    This should NOT be detected as a valid RED line\n");
        
        var detected_line = detect_horizontal_line(board, 4, 0, PieceType.RED);
        
        print("  Line detection result:\n");
        print("    Detected length: %d pieces\n", detected_line.length);
        print("    Continuous check: %s\n", detected_line.is_continuous ? "CONTINUOUS" : "HAS GAPS");
        print("    Should be valid: NO (has gaps)\n");
        print("    Current behavior: %s\n", detected_line.is_valid ? "REMOVES LINE" : "IGNORES LINE");
        
        if (detected_line.is_valid && !detected_line.is_continuous) {
            print("    🐛 PHANTOM LINE BUG CONFIRMED: Non-continuous line detected as valid!\n");
        } else if (!detected_line.is_valid) {
            print("    ✅ CORRECT: Phantom line properly ignored\n");
        }
        
        print("\n");
    }
    
    private void test_interrupted_line_detection() {
        print("Testing Interrupted Line Detection:\n");
        print("EXPECTED: Lines interrupted by different colored pieces should be split\n");
        print("BUG: May be treating interrupted sequences as continuous\n\n");
        
        var board = create_test_board(9, 9);
        
        // Create interrupted line: 3 RED + 1 GREEN + 3 RED
        // Should be detected as two separate 3-piece segments (both invalid)
        board[2, 1] = PieceType.RED;   // Segment 1
        board[2, 2] = PieceType.RED;
        board[2, 3] = PieceType.RED;
        board[2, 4] = PieceType.GREEN; // Interruption
        board[2, 5] = PieceType.RED;   // Segment 2
        board[2, 6] = PieceType.RED;
        board[2, 7] = PieceType.RED;
        
        print("  Test board setup:\n");
        print("    Row 3: [_, RED, RED, RED, GREEN, RED, RED, RED, _]\n");
        print("    Should detect: Two separate 3-piece RED segments (both invalid)\n");
        
        var line1 = detect_horizontal_line(board, 2, 1, PieceType.RED);
        var line2 = detect_horizontal_line(board, 2, 5, PieceType.RED);
        
        print("  Line detection results:\n");
        print("    First segment (cols 2-4): %d pieces, valid: %s\n", 
              line1.length, line1.is_valid ? "YES" : "NO");
        print("    Second segment (cols 6-8): %d pieces, valid: %s\n", 
              line2.length, line2.is_valid ? "YES" : "NO");
        
        // Test if system incorrectly treats this as one long line
        var full_line = detect_horizontal_line_span(board, 2, 1, 7, PieceType.RED);
        print("    Full span detection: %d pieces, valid: %s\n", 
              full_line.length, full_line.is_valid ? "YES" : "NO");
        
        if (full_line.length > 6 && full_line.is_valid) {
            print("    🐛 INTERRUPTION BUG CONFIRMED: Interrupted line treated as continuous!\n");
        } else if (line1.length == 3 && line2.length == 3 && !line1.is_valid && !line2.is_valid) {
            print("    ✅ CORRECT: Interrupted line properly split into invalid segments\n");
        }
        
        print("\n");
    }
    
    private void test_boundary_edge_cases() {
        print("Testing Boundary Edge Cases:\n");
        print("EXPECTED: Line detection should handle board edges correctly\n");
        print("BUG: Coordinate issues near boundaries\n\n");
        
        var board = create_test_board(9, 9);
        
        // Test edge cases
        test_corner_line(board);
        test_edge_line(board);
        test_wrap_around_check(board);
        
        print("\n");
    }
    
    private void test_corner_line(PieceType[,] board) {
        print("  Corner line test (top-left):\n");
        
        // Place 5 pieces starting from corner
        for (int i = 0; i < 5; i++) {
            board[0, i] = PieceType.YELLOW;
        }
        
        var corner_line = detect_horizontal_line(board, 0, 0, PieceType.YELLOW);
        print("    5 pieces from corner: %d detected, valid: %s\n", 
              corner_line.length, corner_line.is_valid ? "YES" : "NO");
    }
    
    private void test_edge_line(PieceType[,] board) {
        print("  Edge line test (right edge):\n");
        
        // Place 5 pieces ending at right edge
        for (int i = 4; i < 9; i++) {
            board[1, i] = PieceType.BLUE;
        }
        
        var edge_line = detect_horizontal_line(board, 1, 4, PieceType.BLUE);
        print("    5 pieces to edge: %d detected, valid: %s\n", 
              edge_line.length, edge_line.is_valid ? "YES" : "NO");
    }
    
    private void test_wrap_around_check(PieceType[,] board) {
        print("  Wrap-around check:\n");
        
        // Place pieces that should NOT wrap around
        board[8, 7] = PieceType.GREEN; // Near bottom-right
        board[8, 8] = PieceType.GREEN; // Bottom-right corner
        board[0, 0] = PieceType.GREEN; // Top-left corner (should not connect)
        
        var wrap_line = detect_horizontal_line_span(board, 8, 7, 2, PieceType.GREEN);
        print("    Wrap-around attempt: %d detected (should be ≤2)\n", wrap_line.length);
        
        if (wrap_line.length > 2) {
            print("    🐛 WRAP-AROUND BUG: Line detection wrapping around board!\n");
        } else {
            print("    ✅ CORRECT: No wrap-around detected\n");
        }
    }
    
    private void test_large_board_coordinate_issues() {
        print("Testing Large Board Coordinate Issues:\n");
        print("EXPECTED: 20x15 board should work correctly\n");
        print("BUG: Coordinate mapping issues on asymmetric board\n\n");
        
        var large_board = create_test_board(15, 20); // 15 rows, 20 columns
        
        // Test coordinate mapping
        print("  Large board (15x20) coordinate tests:\n");
        
        // Place line near the asymmetric dimensions
        for (int i = 15; i < 20; i++) {
            large_board[10, i] = PieceType.RED; // Row 11, cols 16-20
        }
        
        var large_line = detect_horizontal_line(large_board, 10, 15, PieceType.RED);
        print("    Line at row 11, cols 16-20: %d pieces, valid: %s\n", 
              large_line.length, large_line.is_valid ? "YES" : "NO");
        
        // Test boundary access
        bool boundary_safe = test_boundary_access(large_board, 14, 19); // Bottom-right
        print("    Boundary access safety: %s\n", boundary_safe ? "SAFE" : "UNSAFE");
        
        print("\n");
    }
    
    // Helper methods and structures
    
    private struct LineDetectionResult {
        int length;
        bool is_valid;
        bool is_continuous;
        int start_row;
        int start_col;
        int end_row;
        int end_col;
    }
    
    private PieceType[,] create_test_board(int rows, int cols) {
        var board = new PieceType[rows, cols];
        
        // Initialize with empty pieces
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                board[r, c] = PieceType.EMPTY;
            }
        }
        
        return board;
    }
    
    private LineDetectionResult detect_horizontal_line(PieceType[,] board, int row, int col, PieceType piece_type) {
        var result = LineDetectionResult();
        result.start_row = row;
        result.start_col = col;
        
        // Simple horizontal line detection (mimicking the bug-prone logic)
        int length = 0;
        bool continuous = true;
        
        // Count pieces to the right
        for (int c = col; c < board.length[1]; c++) {
            if (board[row, c] == piece_type) {
                length++;
            } else if (board[row, c] == PieceType.EMPTY) {
                // Gap detected
                continuous = false;
                break;
            } else {
                // Different piece type
                break;
            }
        }
        
        result.length = length;
        result.is_continuous = continuous;
        result.is_valid = length >= 5; // Should require 5+ pieces
        result.end_col = col + length - 1;
        result.end_row = row;
        
        return result;
    }
    
    private LineDetectionResult detect_horizontal_line_span(PieceType[,] board, int row, int start_col, int span, PieceType piece_type) {
        var result = LineDetectionResult();
        result.start_row = row;
        result.start_col = start_col;
        
        int matching_pieces = 0;
        bool continuous = true;
        
        for (int i = 0; i < span && (start_col + i) < board.length[1]; i++) {
            int col = start_col + i;
            if (board[row, col] == piece_type) {
                matching_pieces++;
            } else if (board[row, col] != PieceType.EMPTY) {
                continuous = false;
            }
        }
        
        result.length = matching_pieces;
        result.is_continuous = continuous;
        result.is_valid = matching_pieces >= 5 && continuous;
        result.end_col = start_col + span - 1;
        result.end_row = row;
        
        return result;
    }
    
    private bool test_boundary_access(PieceType[,] board, int row, int col) {
        try {
            // Test if we can safely access the position
            var piece = board[row, col];
            
            // Test adjacent positions
            if (row > 0) { var temp = board[row - 1, col]; }
            if (row < board.length[0] - 1) { var temp = board[row + 1, col]; }
            if (col > 0) { var temp = board[row, col - 1]; }
            if (col < board.length[1] - 1) { var temp = board[row, col + 1]; }
            
            return true;
        } catch (Error e) {
            return false;
        }
    }
}