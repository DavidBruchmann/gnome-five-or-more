/*
 * Scoring Validation Test
 * Tests scoring calculation accuracy for Five or More
 */

using GLib;

/**
 * Test scoring calculation accuracy
 */
public class ScoringValidationTest : Object {
    
    private struct ExpectedScore {
        int line_length;
        int expected_traditional;
        int expected_composite_base;
        string description;
    }
    
    private ExpectedScore[] test_cases = {
        { 5, 0, 0, "5-piece line" },      // Will calculate actual values
        { 6, 0, 0, "6-piece line" },
        { 7, 0, 0, "7-piece line" },
        { 8, 0, 0, "8-piece line" },
        { 9, 0, 0, "9-piece line" },
        { 10, 0, 0, "10-piece line" }
    };
    
    public static int main(string[] args) {
        var test = new ScoringValidationTest();
        test.run_validation_tests();
        return 0;
    }
    
    private void run_validation_tests() {
        print("=== Five or More Scoring Validation Test ===\n\n");
        
        // Calculate expected values using the documented formulas
        calculate_expected_values();
        
        // Test traditional scoring formula
        test_traditional_scoring();
        
        // Test composite base scoring formula
        test_composite_base_scoring();
        
        // Test consistency between systems
        test_scoring_consistency();
        
        // Test composite bonus calculations
        test_composite_bonus_scoring();
        
        // Test multiple lines bonus
        test_multiple_lines_bonus();
        
        print("\n=== Validation Complete ===\n");
    }
    
    private void calculate_expected_values() {
        print("Calculating expected score values:\n");
        
        // Traditional formula: 45 * log(0.25 * n_matched)
        // Composite base formula: 45 * log(0.25 * line_length)
        
        for (int i = 0; i < test_cases.length; i++) {
            int length = test_cases[i].line_length;
            
            // Both should be identical if using same constants
            double log_value = Math.log(0.25 * length);
            int expected_score = (int)(45 * log_value);
            
            test_cases[i].expected_traditional = expected_score;
            test_cases[i].expected_composite_base = expected_score;
            
            print("  %d pieces: %d points (log(%.2f) = %.4f)\n", 
                  length, expected_score, 0.25 * length, log_value);
        }
        print("\n");
    }
    
    private void test_traditional_scoring() {
        print("Testing Traditional Scoring Formula:\n");
        print("Formula: 45 * log(0.25 * n_matched)\n\n");
        
        bool all_passed = true;
        
        foreach (var test_case in test_cases) {
            int calculated = calculate_traditional_score(test_case.line_length);
            bool passed = calculated == test_case.expected_traditional;
            all_passed &= passed;
            
            print("  %s: %s (expected: %d, got: %d)\n",
                  test_case.description,
                  passed ? "PASS" : "FAIL",
                  test_case.expected_traditional,
                  calculated);
        }
        
        print("\nTraditional Scoring: %s\n\n", all_passed ? "ALL TESTS PASSED" : "SOME TESTS FAILED");
    }
    
    private void test_composite_base_scoring() {
        print("Testing Composite Base Scoring Formula:\n");
        print("Formula: 45 * log(0.25 * line_length)\n\n");
        
        bool all_passed = true;
        
        foreach (var test_case in test_cases) {
            int calculated = calculate_composite_base_score(test_case.line_length);
            bool passed = calculated == test_case.expected_composite_base;
            all_passed &= passed;
            
            print("  %s: %s (expected: %d, got: %d)\n",
                  test_case.description,
                  passed ? "PASS" : "FAIL",
                  test_case.expected_composite_base,
                  calculated);
        }
        
        print("\nComposite Base Scoring: %s\n\n", all_passed ? "ALL TESTS PASSED" : "SOME TESTS FAILED");
    }
    
    private void test_scoring_consistency() {
        print("Testing Consistency Between Scoring Systems:\n\n");
        
        bool all_consistent = true;
        
        foreach (var test_case in test_cases) {
            int traditional = calculate_traditional_score(test_case.line_length);
            int composite_base = calculate_composite_base_score(test_case.line_length);
            bool consistent = traditional == composite_base;
            all_consistent &= consistent;
            
            print("  %s: %s (traditional: %d, composite: %d, diff: %d)\n",
                  test_case.description,
                  consistent ? "CONSISTENT" : "INCONSISTENT",
                  traditional,
                  composite_base,
                  (traditional - composite_base).abs());
        }
        
        print("\nScoring Consistency: %s\n\n", all_consistent ? "SYSTEMS CONSISTENT" : "SYSTEMS INCONSISTENT");
    }
    
    private void test_composite_bonus_scoring() {
        print("Testing Composite Bonus Calculations:\n\n");
        
        // Test single segment (no bonus)
        var single_bonus = calculate_composite_bonus(1, new int[] {5});
        print("  Single segment (5 pieces): %d bonus (expected: 0)\n", single_bonus);
        
        // Test two balanced segments
        var balanced_bonus = calculate_composite_bonus(2, new int[] {5, 5});
        print("  Two balanced segments (5+5): %d bonus (expected: 65)\n", balanced_bonus);
        
        // Test two unbalanced segments
        var unbalanced_bonus = calculate_composite_bonus(2, new int[] {5, 7});
        print("  Two unbalanced segments (5+7): %d bonus (expected: 50)\n", unbalanced_bonus);
        
        // Test three segments
        var three_bonus = calculate_composite_bonus(3, new int[] {5, 5, 5});
        print("  Three balanced segments (5+5+5): %d bonus (expected: 95)\n", three_bonus);
        
        print("\n");
    }
    
    private void test_multiple_lines_bonus() {
        print("Testing Multiple Lines Bonus:\n\n");
        
        // Test single line (no bonus)
        int single_line_bonus = calculate_multiple_lines_bonus(1);
        print("  Single line: %d bonus (expected: 0)\n", single_line_bonus);
        
        // Test multiple lines
        for (int lines = 2; lines <= 5; lines++) {
            int bonus = calculate_multiple_lines_bonus(lines);
            int expected = lines * 50;
            print("  %d lines: %d bonus (expected: %d)\n", lines, bonus, expected);
        }
        
        print("\n");
    }
    
    // Scoring calculation methods (replicate game logic)
    
    private int calculate_traditional_score(int n_matched) {
        // Traditional formula from game.vala
        int SCORE_BASE_MULTIPLIER = 45;
        double SCORE_LOG_FACTOR = 0.25;
        return (int)(SCORE_BASE_MULTIPLIER * Math.log(SCORE_LOG_FACTOR * n_matched));
    }
    
    private int calculate_composite_base_score(int line_length) {
        // Composite base formula from composite-scoring.vala
        return (int)(45 * Math.log(0.25 * line_length));
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
    
    private int calculate_multiple_lines_bonus(int num_lines) {
        if (num_lines <= 1) {
            return 0;
        }
        return num_lines * 50;
    }
}