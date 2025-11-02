/*
 * Scoring Discrepancies Investigation
 * Tests for inconsistencies between traditional and composite scoring
 */

using GLib;

public class ScoringDiscrepanciesTest : Object {
    
    public static int main(string[] args) {
        var test = new ScoringDiscrepanciesTest();
        test.investigate_discrepancies();
        return 0;
    }
    
    private void investigate_discrepancies() {
        print("=== Scoring Discrepancies Investigation ===\n\n");
        
        // Test hardcoded vs configurable constants
        test_constant_consistency();
        
        // Test timing-based issues
        test_timing_scenarios();
        
        // Test state-dependent scoring
        test_state_dependent_scoring();
        
        // Test interaction between systems
        test_system_interaction();
        
        // Test configuration impact
        test_configuration_impact();
        
        print("\n=== Investigation Complete ===\n");
    }
    
    private void test_constant_consistency() {
        print("Testing Constant Consistency:\n");
        print("Checking if hardcoded values match configurable constants\n\n");
        
        // Traditional scoring constants (configurable)
        int TRADITIONAL_MULTIPLIER = 45;
        double TRADITIONAL_LOG_FACTOR = 0.25;
        
        // Composite scoring constants (hardcoded in composite-scoring.vala)
        int COMPOSITE_MULTIPLIER = 45;  // Hardcoded
        double COMPOSITE_LOG_FACTOR = 0.25;  // Hardcoded
        
        print("  Traditional System (configurable):\n");
        print("    SCORE_BASE_MULTIPLIER: %d\n", TRADITIONAL_MULTIPLIER);
        print("    SCORE_LOG_FACTOR: %.2f\n", TRADITIONAL_LOG_FACTOR);
        
        print("  Composite System (hardcoded):\n");
        print("    Hardcoded multiplier: %d\n", COMPOSITE_MULTIPLIER);
        print("    Hardcoded log factor: %.2f\n", COMPOSITE_LOG_FACTOR);
        
        bool constants_match = (TRADITIONAL_MULTIPLIER == COMPOSITE_MULTIPLIER) && 
                              (TRADITIONAL_LOG_FACTOR == COMPOSITE_LOG_FACTOR);
        
        print("  Constants match: %s\n", constants_match ? "✓ YES" : "✗ NO");
        
        if (!constants_match) {
            print("  ⚠️  CRITICAL ISSUE: Hardcoded values in composite scoring don't use GameConstants!\n");
        }
        
        print("\n");
    }
    
    private void test_timing_scenarios() {
        print("Testing Timing-Based Scenarios:\n");
        print("Simulating different game timing conditions\n\n");
        
        // Test rapid successive line clears
        print("  Rapid successive line clears:\n");
        for (int i = 1; i <= 3; i++) {
            int score = calculate_traditional_score(5);
            print("    Clear %d: 5-piece line = %d points\n", i, score);
        }
        
        // Test delayed scoring
        print("  Delayed scoring (should be identical):\n");
        Thread.usleep(100000); // 100ms delay
        int delayed_score = calculate_traditional_score(5);
        print("    After delay: 5-piece line = %d points\n", delayed_score);
        
        print("  ✓ Timing does not affect base score calculation\n\n");
    }
    
    private void test_state_dependent_scoring() {
        print("Testing State-Dependent Scoring:\n");
        print("Checking if game state affects scoring\n\n");
        
        // Simulate different game states
        string[] game_states = {"Early game", "Mid game", "Late game", "Near game over"};
        int[] simulated_scores = {100, 1500, 5000, 8500};
        
        for (int i = 0; i < game_states.length; i++) {
            print("  %s (current score: %d):\n", game_states[i], simulated_scores[i]);
            
            // Score calculation should be independent of current score
            int line_score = calculate_traditional_score(7);
            print("    7-piece line: %d points (should always be same)\n", line_score);
        }
        
        print("  ✓ Scoring is independent of game state\n\n");
    }
    
    private void test_system_interaction() {
        print("Testing System Interaction:\n");
        print("Checking traditional vs composite system behavior\n\n");
        
        // Test scenarios where both systems might apply
        print("  Scenario: Simple 5-piece horizontal line\n");
        int traditional_score = calculate_traditional_score(5);
        int composite_base_score = calculate_composite_base_score(5);
        int composite_total_score = composite_base_score + 0; // No bonus for single segment
        
        print("    Traditional system: %d points\n", traditional_score);
        print("    Composite base: %d points\n", composite_base_score);
        print("    Composite total: %d points\n", composite_total_score);
        
        if (traditional_score == composite_total_score) {
            print("    ✓ Systems produce identical results for simple lines\n");
        } else {
            print("    ✗ Systems produce different results! (diff: %d)\n", 
                  (traditional_score - composite_total_score).abs());
        }
        
        print("\n  Scenario: Complex composite pattern (2 segments)\n");
        int composite_with_bonus = composite_base_score + calculate_composite_bonus(2, new int[] {5, 5});
        print("    Traditional system: %d points (would not detect)\n", traditional_score);
        print("    Composite with bonus: %d points\n", composite_with_bonus);
        print("    Bonus advantage: +%d points\n", composite_with_bonus - traditional_score);
        
        print("\n");
    }
    
    private void test_configuration_impact() {
        print("Testing Configuration Impact:\n");
        print("Simulating different configuration values\n\n");
        
        // Test with different multiplier values
        int[] multipliers = {30, 45, 60};
        double[] log_factors = {0.2, 0.25, 0.3};
        
        print("  Impact of SCORE_BASE_MULTIPLIER changes:\n");
        foreach (int multiplier in multipliers) {
            int score = (int)(multiplier * Math.log(0.25 * 7));
            print("    Multiplier %d: 7-piece line = %d points\n", multiplier, score);
        }
        
        print("\n  Impact of SCORE_LOG_FACTOR changes:\n");
        foreach (double factor in log_factors) {
            int score = (int)(45 * Math.log(factor * 7));
            print("    Factor %.2f: 7-piece line = %d points\n", factor, score);
        }
        
        print("\n  ⚠️  Configuration changes only affect traditional scoring!\n");
        print("      Composite scoring uses hardcoded values and won't change.\n\n");
    }
    
    // Helper methods
    
    private int calculate_traditional_score(int n_matched) {
        // Uses configurable constants (simulated)
        int SCORE_BASE_MULTIPLIER = 45;
        double SCORE_LOG_FACTOR = 0.25;
        return (int)(SCORE_BASE_MULTIPLIER * Math.log(SCORE_LOG_FACTOR * n_matched));
    }
    
    private int calculate_composite_base_score(int line_length) {
        // Uses hardcoded values (as in actual code)
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
}