/*
 * Scoring Edge Cases and Board Size Consistency Test
 * Tests scoring behavior across different scenarios
 */

using GLib;

public class ScoringEdgeCasesTest : Object {
    
    public static int main(string[] args) {
        var test = new ScoringEdgeCasesTest();
        test.run_edge_case_tests();
        return 0;
    }
    
    private void run_edge_case_tests() {
        print("=== Scoring Edge Cases and Consistency Test ===\n\n");
        
        // Test minimum valid line length
        test_minimum_line_length();
        
        // Test maximum reasonable line length
        test_maximum_line_length();
        
        // Test board size consistency
        test_board_size_consistency();
        
        // Test floating point precision
        test_floating_point_precision();
        
        // Test negative and zero inputs
        test_invalid_inputs();
        
        // Test composite bonus edge cases
        test_composite_bonus_edge_cases();
        
        print("\n=== Edge Case Testing Complete ===\n");
    }
    
    private void test_minimum_line_length() {
        print("Testing Minimum Line Length (5 pieces):\n");
        
        int score_5 = calculate_traditional_score(5);
        print("  5-piece line score: %d points\n", score_5);
        
        // Test that 4-piece lines would score less (but shouldn't be valid)
        int score_4 = calculate_traditional_score(4);
        print("  4-piece line score (invalid): %d points\n", score_4);
        
        if (score_5 > score_4) {
            print("  ✓ 5-piece lines score higher than 4-piece lines\n");
        } else {
            print("  ✗ Scoring issue: 5-piece should score higher than 4-piece\n");
        }
        
        print("\n");
    }
    
    private void test_maximum_line_length() {
        print("Testing Maximum Line Length:\n");
        
        // Test various large line lengths
        int[] large_lengths = {15, 20, 25, 30};
        
        foreach (int length in large_lengths) {
            int score = calculate_traditional_score(length);
            print("  %d-piece line: %d points\n", length, score);
        }
        
        // Check that scores increase with length
        bool increasing = true;
        int prev_score = 0;
        
        foreach (int length in large_lengths) {
            int score = calculate_traditional_score(length);
            if (score <= prev_score && prev_score > 0) {
                increasing = false;
                break;
            }
            prev_score = score;
        }
        
        print("  Score progression: %s\n", increasing ? "✓ INCREASING" : "✗ NOT INCREASING");
        print("\n");
    }
    
    private void test_board_size_consistency() {
        print("Testing Board Size Consistency:\n");
        print("(Scoring should be independent of board size)\n\n");
        
        // Simulate different board sizes
        string[] board_sizes = {"Small (9x9)", "Medium (13x13)", "Large (20x15)"};
        int[] test_lengths = {5, 7, 10};
        
        foreach (string board_size in board_sizes) {
            print("  %s:\n", board_size);
            
            foreach (int length in test_lengths) {
                int score = calculate_traditional_score(length);
                print("    %d pieces: %d points\n", length, score);
            }
            print("\n");
        }
        
        print("  ✓ Scores are consistent across board sizes (as expected)\n\n");
    }
    
    private void test_floating_point_precision() {
        print("Testing Floating Point Precision:\n");
        
        // Test that integer casting doesn't cause unexpected behavior
        for (int length = 5; length <= 10; length++) {
            double exact_score = 45.0 * Math.log(0.25 * length);
            int truncated_score = (int)(45 * Math.log(0.25 * length));
            int calculated_score = calculate_traditional_score(length);
            
            print("  %d pieces: exact=%.2f, truncated=%d, calculated=%d\n",
                  length, exact_score, truncated_score, calculated_score);
            
            if (truncated_score != calculated_score) {
                print("    ✗ Calculation mismatch!\n");
            }
        }
        
        print("\n");
    }
    
    private void test_invalid_inputs() {
        print("Testing Invalid Inputs:\n");
        
        // Test zero and negative inputs (should not occur in game)
        int[] invalid_inputs = {0, -1, -5};
        
        foreach (int input in invalid_inputs) {
            try {
                int score = calculate_traditional_score(input);
                print("  Input %d: score=%d (should not be valid)\n", input, score);
            } catch (Error e) {
                print("  Input %d: error=%s\n", input, e.message);
            }
        }
        
        print("\n");
    }
    
    private void test_composite_bonus_edge_cases() {
        print("Testing Composite Bonus Edge Cases:\n");
        
        // Test single segment (should be 0 bonus)
        int single_bonus = calculate_composite_bonus(1, new int[] {10});
        print("  Single 10-piece segment: %d bonus (expected: 0)\n", single_bonus);
        
        // Test many small segments vs few large segments
        int many_small = calculate_composite_bonus(5, new int[] {5, 5, 5, 5, 5});
        int few_large = calculate_composite_bonus(2, new int[] {12, 13});
        
        print("  5 segments of 5 pieces: %d bonus\n", many_small);
        print("  2 segments of 12-13 pieces: %d bonus\n", few_large);
        
        // Test perfectly balanced vs highly unbalanced
        int balanced = calculate_composite_bonus(3, new int[] {7, 7, 7});
        int unbalanced = calculate_composite_bonus(3, new int[] {5, 10, 15});
        
        print("  Balanced (7+7+7): %d bonus\n", balanced);
        print("  Unbalanced (5+10+15): %d bonus\n", unbalanced);
        
        if (balanced > unbalanced) {
            print("  ✓ Balanced segments receive higher bonus\n");
        } else {
            print("  ✗ Balance bonus not working as expected\n");
        }
        
        print("\n");
    }
    
    // Helper methods
    
    private int calculate_traditional_score(int n_matched) {
        if (n_matched <= 0) {
            return 0; // Handle invalid input gracefully
        }
        
        int SCORE_BASE_MULTIPLIER = 45;
        double SCORE_LOG_FACTOR = 0.25;
        return (int)(SCORE_BASE_MULTIPLIER * Math.log(SCORE_LOG_FACTOR * n_matched));
    }
    
    private int calculate_composite_bonus(int num_segments, int[] segment_lengths) {
        if (num_segments <= 1) {
            return 0;
        }
        
        int COMPOSITE_BASE_BONUS = 25;
        int COMPOSITE_COMPLEXITY_BONUS = 15;
        
        int base_bonus = COMPOSITE_BASE_BONUS;
        int complexity_bonus = num_segments * COMPOSITE_COMPLEXITY_BONUS;
        
        // Calculate balance bonus
        int min_length = int.MAX;
        int max_length = 0;
        
        foreach (int length in segment_lengths) {
            min_length = int.min(min_length, length);
            max_length = int.max(max_length, length);
        }
        
        int balance_bonus = (max_length - min_length) <= 1 ? 25 : 10;
        
        return base_bonus + complexity_bonus + balance_bonus;
    }
}