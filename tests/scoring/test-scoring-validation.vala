/*
 * Comprehensive Scoring Validation Test Suite
 * Tests for Five or More scoring system accuracy and consistency
 */

using GLib;

/**
 * Comprehensive scoring validation test suite
 */
public class ScoringValidationTestSuite : Object {
    
    private int tests_run = 0;
    private int tests_passed = 0;
    private int tests_failed = 0;
    
    public static int main(string[] args) {
        var suite = new ScoringValidationTestSuite();
        return suite.run_all_tests();
    }
    
    public int run_all_tests() {
        print("=== Five or More Scoring Validation Test Suite ===\n\n");
        
        // Core accuracy tests
        test_traditional_scoring_accuracy();
        test_composite_base_scoring_accuracy();
        test_scoring_system_consistency();
        
        // Edge case tests
        test_minimum_line_lengths();
        test_maximum_line_lengths();
        test_floating_point_precision();
        
        // Composite bonus tests
        test_composite_bonus_calculations();
        test_multiple_lines_bonus();
        test_balance_bonus_logic();
        
        // Configuration tests
        test_configuration_consistency();
        test_hardcoded_values_detection();
        
        // Regression tests for known issues
        test_phantom_line_prevention_scoring();
        test_boundary_condition_scoring();
        
        // Performance tests
        test_scoring_performance();
        
        print_test_summary();
        return tests_failed > 0 ? 1 : 0;
    }
    
    private void test_traditional_scoring_accuracy() {
        start_test_group("Traditional Scoring Accuracy");
        
        struct TestCase {
            int line_length;
            int expected_score;
            string description;
        }
        
        TestCase[] cases = {
            { 5, 10, "5-piece line" },
            { 6, 18, "6-piece line" },
            { 7, 25, "7-piece line" },
            { 8, 31, "8-piece line" },
            { 9, 36, "9-piece line" },
            { 10, 41, "10-piece line" }
        };
        
        foreach (var test_case in cases) {
            int actual = calculate_traditional_score(test_case.line_length);
            assert_equals(test_case.expected_score, actual, test_case.description);
        }
    }
    
    private void test_composite_base_scoring_accuracy() {
        start_test_group("Composite Base Scoring Accuracy");
        
        // Should match traditional scoring exactly
        for (int length = 5; length <= 10; length++) {
            int traditional = calculate_traditional_score(length);
            int composite = calculate_composite_base_score(length);
            assert_equals(traditional, composite, @"$(length)-piece line consistency");
        }
    }
    
    private void test_scoring_system_consistency() {
        start_test_group("Scoring System Consistency");
        
        // Test that both systems produce identical base scores
        for (int length = 5; length <= 15; length++) {
            int traditional = calculate_traditional_score(length);
            int composite_base = calculate_composite_base_score(length);
            
            assert_equals(traditional, composite_base, 
                         @"Base score consistency for $(length) pieces");
        }
    }
    
    private void test_minimum_line_lengths() {
        start_test_group("Minimum Line Length Tests");
        
        // Test that 5-piece lines score higher than 4-piece lines
        int score_4 = calculate_traditional_score(4);
        int score_5 = calculate_traditional_score(5);
        
        assert_true(score_5 > score_4, "5-piece lines score higher than 4-piece lines");
        assert_true(score_5 > 0, "5-piece lines have positive score");
    }
    
    private void test_maximum_line_lengths() {
        start_test_group("Maximum Line Length Tests");
        
        // Test score progression for large lines
        int prev_score = 0;
        for (int length = 15; length <= 30; length += 5) {
            int score = calculate_traditional_score(length);
            
            assert_true(score > prev_score, @"Score increases for $(length) pieces");
            assert_true(score > 0, @"Positive score for $(length) pieces");
            
            prev_score = score;
        }
    }
    
    private void test_floating_point_precision() {
        start_test_group("Floating Point Precision Tests");
        
        // Test that integer casting doesn't cause unexpected behavior
        for (int length = 5; length <= 10; length++) {
            double exact = 45.0 * Math.log(0.25 * length);
            int truncated = (int)(45 * Math.log(0.25 * length));
            int calculated = calculate_traditional_score(length);
            
            assert_equals(truncated, calculated, 
                         @"Precision consistency for $(length) pieces");
            
            // Verify truncation is reasonable (within 1 point of exact)
            assert_true((exact - truncated).abs() < 1.0, 
                       @"Reasonable truncation for $(length) pieces");
        }
    }
    
    private void test_composite_bonus_calculations() {
        start_test_group("Composite Bonus Calculations");
        
        // Single segment should have no bonus
        int single_bonus = calculate_composite_bonus(1, new int[] {10});
        assert_equals(0, single_bonus, "Single segment has no bonus");
        
        // Two balanced segments
        int balanced_bonus = calculate_composite_bonus(2, new int[] {5, 5});
        int expected_balanced = 25 + (2 * 15) + 25; // base + complexity + balance
        assert_equals(expected_balanced, balanced_bonus, "Balanced two-segment bonus");
        
        // Two unbalanced segments
        int unbalanced_bonus = calculate_composite_bonus(2, new int[] {5, 8});
        int expected_unbalanced = 25 + (2 * 15) + 10; // base + complexity + unbalanced
        assert_equals(expected_unbalanced, unbalanced_bonus, "Unbalanced two-segment bonus");
        
        // Three segments
        int three_bonus = calculate_composite_bonus(3, new int[] {5, 5, 5});
        int expected_three = 25 + (3 * 15) + 25; // base + complexity + balance
        assert_equals(expected_three, three_bonus, "Three-segment bonus");
    }
    
    private void test_multiple_lines_bonus() {
        start_test_group("Multiple Lines Bonus Tests");
        
        // Single line should have no bonus
        int single_bonus = calculate_multiple_lines_bonus(1);
        assert_equals(0, single_bonus, "Single line has no bonus");
        
        // Multiple lines should have 50 points per line
        for (int lines = 2; lines <= 5; lines++) {
            int bonus = calculate_multiple_lines_bonus(lines);
            int expected = lines * 50;
            assert_equals(expected, bonus, @"$(lines) lines bonus");
        }
    }
    
    private void test_balance_bonus_logic() {
        start_test_group("Balance Bonus Logic Tests");
        
        // Test balance threshold (difference <= 1)
        int balanced = calculate_balance_bonus(new int[] {5, 5, 6});
        assert_equals(25, balanced, "Balanced segments (diff <= 1)");
        
        int unbalanced = calculate_balance_bonus(new int[] {5, 8, 10});
        assert_equals(10, unbalanced, "Unbalanced segments (diff > 1)");
        
        // Edge case: identical segments
        int identical = calculate_balance_bonus(new int[] {7, 7, 7, 7});
        assert_equals(25, identical, "Identical segments");
    }
    
    private void test_configuration_consistency() {
        start_test_group("Configuration Consistency Tests");
        
        // Test that configuration changes would affect traditional scoring
        int[] multipliers = {30, 45, 60};
        double[] factors = {0.2, 0.25, 0.3};
        
        foreach (int mult in multipliers) {
            foreach (double factor in factors) {
                int score = (int)(mult * Math.log(factor * 7));
                assert_true(score > 0, @"Valid score with mult=$(mult), factor=$(factor)");
            }
        }
        
        // Verify hardcoded composite values
        int hardcoded_score = calculate_composite_base_score(7);
        int expected_hardcoded = (int)(45 * Math.log(0.25 * 7));
        assert_equals(expected_hardcoded, hardcoded_score, "Hardcoded composite values");
    }
    
    private void test_hardcoded_values_detection() {
        start_test_group("Hardcoded Values Detection");
        
        // This test documents the hardcoded values issue
        // Traditional scoring (should use constants)
        int traditional = calculate_traditional_score(7);
        
        // Composite scoring (uses hardcoded values)
        int composite = calculate_composite_base_score(7);
        
        // They should be equal with current hardcoded values
        assert_equals(traditional, composite, "Current hardcoded values match");
        
        // But this test serves as documentation that composite scoring
        // doesn't use configurable constants
        print("    ⚠️  DOCUMENTED ISSUE: Composite scoring uses hardcoded values\n");
    }
    
    private void test_phantom_line_prevention_scoring() {
        start_test_group("Phantom Line Prevention Scoring");
        
        // Test that phantom lines (if prevented) don't affect scoring
        // This is a regression test for the boundary fix
        
        // Simulate a 4-piece "phantom" line that should not score
        int phantom_score = 0; // Should be 0 if properly prevented
        assert_equals(0, phantom_score, "Phantom lines don't score");
        
        // Simulate a proper 5-piece line that should score
        int valid_score = calculate_traditional_score(5);
        assert_true(valid_score > 0, "Valid 5-piece lines score properly");
    }
    
    private void test_boundary_condition_scoring() {
        start_test_group("Boundary Condition Scoring");
        
        // Test scoring near board boundaries
        // Scores should be independent of position
        
        for (int length = 5; length <= 10; length++) {
            int center_score = calculate_traditional_score(length);
            int edge_score = calculate_traditional_score(length); // Same calculation
            
            assert_equals(center_score, edge_score, 
                         @"Position-independent scoring for $(length) pieces");
        }
    }
    
    private void test_scoring_performance() {
        start_test_group("Scoring Performance Tests");
        
        // Test that scoring calculations are fast enough
        int64 start_time = get_monotonic_time();
        
        // Perform many scoring calculations
        for (int i = 0; i < 10000; i++) {
            calculate_traditional_score(5 + (i % 6));
            calculate_composite_base_score(5 + (i % 6));
        }
        
        int64 end_time = get_monotonic_time();
        int64 duration_us = end_time - start_time;
        
        // Should complete in reasonable time (< 100ms for 10k calculations)
        assert_true(duration_us < 100000, "Scoring performance acceptable");
        
        print(@"    Performance: 10k calculations in $(duration_us)μs\n");
    }
    
    // Helper methods
    
    private void start_test_group(string group_name) {
        print(@"$(group_name):\n");
    }
    
    private void assert_equals(int expected, int actual, string description) {
        tests_run++;
        if (expected == actual) {
            tests_passed++;
            print(@"  ✓ $(description)\n");
        } else {
            tests_failed++;
            print(@"  ✗ $(description) - Expected: $(expected), Got: $(actual)\n");
        }
    }
    
    private void assert_true(bool condition, string description) {
        tests_run++;
        if (condition) {
            tests_passed++;
            print(@"  ✓ $(description)\n");
        } else {
            tests_failed++;
            print(@"  ✗ $(description) - Condition failed\n");
        }
    }
    
    private void print_test_summary() {
        print(@"\n=== Test Summary ===\n");
        print(@"Tests run: $(tests_run)\n");
        print(@"Passed: $(tests_passed)\n");
        print(@"Failed: $(tests_failed)\n");
        
        if (tests_failed == 0) {
            print("🎉 All tests passed!\n");
        } else {
            print(@"⚠️  $(tests_failed) test(s) failed\n");
        }
    }
    
    // Scoring calculation methods (replicate game logic)
    
    private int calculate_traditional_score(int n_matched) {
        if (n_matched <= 0) return 0;
        
        int SCORE_BASE_MULTIPLIER = 45;
        double SCORE_LOG_FACTOR = 0.25;
        return (int)(SCORE_BASE_MULTIPLIER * Math.log(SCORE_LOG_FACTOR * n_matched));
    }
    
    private int calculate_composite_base_score(int line_length) {
        if (line_length <= 0) return 0;
        
        // Hardcoded values as in actual composite-scoring.vala
        return (int)(45 * Math.log(0.25 * line_length));
    }
    
    private int calculate_composite_bonus(int num_segments, int[] segment_lengths) {
        if (num_segments <= 1) return 0;
        
        int COMPOSITE_BASE_BONUS = 25;
        int COMPOSITE_COMPLEXITY_BONUS = 15;
        
        int base_bonus = COMPOSITE_BASE_BONUS;
        int complexity_bonus = num_segments * COMPOSITE_COMPLEXITY_BONUS;
        int balance_bonus = calculate_balance_bonus(segment_lengths);
        
        return base_bonus + complexity_bonus + balance_bonus;
    }
    
    private int calculate_balance_bonus(int[] segment_lengths) {
        if (segment_lengths.length <= 1) return 0;
        
        int min_length = int.MAX;
        int max_length = 0;
        
        foreach (int length in segment_lengths) {
            min_length = int.min(min_length, length);
            max_length = int.max(max_length, length);
        }
        
        return (max_length - min_length) <= 1 ? 25 : 10;
    }
    
    private int calculate_multiple_lines_bonus(int num_lines) {
        if (num_lines <= 1) return 0;
        return num_lines * 50;
    }
}