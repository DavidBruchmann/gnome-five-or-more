/*
 * Debug Statistics Panel Updates
 * Test to verify statistics panel functionality
 */

using Gtk;

void main(string[] args) {
    Gtk.init(ref args);
    
    print("Testing Statistics Panel Updates\n");
    print("================================\n");
    
    // Create a settings object
    var settings = new GLib.Settings("org.gnome.five-or-more");
    
    // Create a statistics panel
    var stats_panel = new StatisticsPanel(settings);
    
    // Test session statistics
    var session_stats = stats_panel.player_stats.get_session_statistics();
    print("Initial session stats:\n");
    print("  Games played: %d\n", session_stats.games_played);
    print("  Total lines: %d\n", session_stats.total_lines);
    print("  Best score: %d\n", session_stats.best_score);
    
    // Test line achievement recording
    print("\nTesting line achievement recording...\n");
    stats_panel.player_stats.record_line_achievement(5);
    stats_panel.player_stats.record_line_achievement(7);
    stats_panel.player_stats.record_line_achievement(5);
    
    // Check updated session stats
    session_stats = stats_panel.player_stats.get_session_statistics();
    print("After recording line achievements:\n");
    print("  Games played: %d\n", session_stats.games_played);
    print("  Total lines: %d\n", session_stats.total_lines);
    print("  Best score: %d\n", session_stats.best_score);
    
    // Test line statistics
    var line_stats = stats_panel.player_stats.get_lines_statistics();
    print("\nLine statistics:\n");
    for (int length = 5; length <= 12; length++) {
        int count = line_stats.has_key(length) ? line_stats.get(length) : 0;
        if (count > 0) {
            print("  %d-line: %d times\n", length, count);
        }
    }
    
    // Test game completion
    print("\nTesting game completion...\n");
    stats_panel.player_stats.record_game_completion(1500);
    
    session_stats = stats_panel.player_stats.get_session_statistics();
    print("After game completion:\n");
    print("  Games played: %d\n", session_stats.games_played);
    print("  Total lines: %d\n", session_stats.total_lines);
    print("  Best score: %d\n", session_stats.best_score);
    
    print("\nOverall statistics:\n");
    print("  Total games: %d\n", stats_panel.player_stats.get_total_games_played());
    print("  User best: %d\n", stats_panel.player_stats.get_user_best_score());
    
    print("\nStatistics panel test completed successfully!\n");
}

// Include the required classes (simplified versions for testing)
internal class StatisticsPanel : Object {
    public PlayerStatistics player_stats;
    
    public StatisticsPanel(GLib.Settings settings) {
        this.player_stats = new PlayerStatistics(settings);
        player_stats.load_from_settings();
    }
}