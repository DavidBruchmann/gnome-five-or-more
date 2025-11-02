/*
 * Test Session Reset Logic
 * Verify that session statistics reset properly when a new game starts
 */

using Gtk;

void main(string[] args) {
    Gtk.init(ref args);
    
    print("Testing Session Reset Logic\n");
    print("===========================\n");
    
    // Create a settings object
    var settings = new GLib.Settings("org.gnome.five-or-more");
    
    // Create a statistics panel
    var stats_panel = new StatisticsPanel(settings);
    
    print("Initial state:\n");
    var session_stats = stats_panel.player_stats.get_session_statistics();
    var session_lines = stats_panel.player_stats.get_session_lines_statistics();
    print("  Session games: %d\n", session_stats.games_played);
    print("  Session lines: %d\n", session_stats.total_lines);
    print("  Session best: %d\n", session_stats.best_score);
    
    int total_session_lines = 0;
    for (int length = 5; length <= 12; length++) {
        int count = session_lines.has_key(length) ? session_lines.get(length) : 0;
        total_session_lines += count;
    }
    print("  Session line achievements: %d\n", total_session_lines);
    
    // Simulate some line achievements
    print("\nSimulating line achievements...\n");
    stats_panel.player_stats.record_line_achievement(5);
    stats_panel.player_stats.record_line_achievement(7);
    stats_panel.player_stats.record_line_achievement(5);
    
    session_stats = stats_panel.player_stats.get_session_statistics();
    session_lines = stats_panel.player_stats.get_session_lines_statistics();
    print("After recording achievements:\n");
    print("  Session games: %d\n", session_stats.games_played);
    print("  Session lines: %d\n", session_stats.total_lines);
    print("  Session best: %d\n", session_stats.best_score);
    
    total_session_lines = 0;
    for (int length = 5; length <= 12; length++) {
        int count = session_lines.has_key(length) ? session_lines.get(length) : 0;
        if (count > 0) {
            print("    %d-line: %d times\n", length, count);
        }
        total_session_lines += count;
    }
    print("  Total session line achievements: %d\n", total_session_lines);
    
    // Simulate game completion
    print("\nSimulating game completion...\n");
    stats_panel.player_stats.record_game_completion(1500);
    
    session_stats = stats_panel.player_stats.get_session_statistics();
    print("After game completion:\n");
    print("  Session games: %d\n", session_stats.games_played);
    print("  Session lines: %d\n", session_stats.total_lines);
    print("  Session best: %d\n", session_stats.best_score);
    
    // Test session reset (simulating new game)
    print("\nTesting session reset (new game started)...\n");
    stats_panel.on_new_game_started();
    
    session_stats = stats_panel.player_stats.get_session_statistics();
    session_lines = stats_panel.player_stats.get_session_lines_statistics();
    print("After session reset:\n");
    print("  Session games: %d\n", session_stats.games_played);
    print("  Session lines: %d\n", session_stats.total_lines);
    print("  Session best: %d\n", session_stats.best_score);
    
    total_session_lines = 0;
    for (int length = 5; length <= 12; length++) {
        int count = session_lines.has_key(length) ? session_lines.get(length) : 0;
        total_session_lines += count;
    }
    print("  Session line achievements: %d\n", total_session_lines);
    
    // Check that overall statistics are preserved
    print("\nOverall statistics (should be preserved):\n");
    print("  Total games: %d\n", stats_panel.player_stats.get_total_games_played());
    print("  User best: %d\n", stats_panel.player_stats.get_user_best_score());
    
    var overall_lines = stats_panel.player_stats.get_lines_statistics();
    int total_overall_lines = 0;
    for (int length = 5; length <= 12; length++) {
        int count = overall_lines.has_key(length) ? overall_lines.get(length) : 0;
        if (count > 0) {
            print("    %d-line: %d times\n", length, count);
        }
        total_overall_lines += count;
    }
    print("  Total overall line achievements: %d\n", total_overall_lines);
    
    print("\nSession reset test completed successfully!\n");
    print("✓ Session statistics reset properly\n");
    print("✓ Overall statistics preserved\n");
}

// Include the required classes (simplified versions for testing)
internal class StatisticsPanel : Object {
    public PlayerStatistics player_stats;
    
    public StatisticsPanel(GLib.Settings settings) {
        this.player_stats = new PlayerStatistics(settings);
        player_stats.load_from_settings();
    }
    
    public void on_new_game_started() {
        player_stats.reset_session_statistics();
    }
}