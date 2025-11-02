/*
 * Player Statistics for Five or More
 * Copyright © 2024 Five or More Contributors
 *
 * This game is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

using Gee;

/**
 * Session statistics structure
 */
internal struct SessionStatistics {
    public int games_played;
    public int total_lines;
    public int best_score;
}

/**
 * Player statistics tracking and persistence
 */
internal class PlayerStatistics : Object {
    private GLib.Settings settings;
    
    // Statistics data
    private HashMap<int, int> lines_by_length; // Overall persistent line achievements
    private HashMap<int, int> session_lines_by_length; // Current session line achievements
    private int total_games_played;
    private int user_best_score;
    private int global_best_score;
    
    // Session tracking
    private SessionStatistics session_stats;
    
    // File paths for persistent storage
    private string stats_file_path;
    private string global_stats_file_path;
    
    public PlayerStatistics(GLib.Settings settings) {
        this.settings = settings;
        this.lines_by_length = new HashMap<int, int>();
        this.session_lines_by_length = new HashMap<int, int>();
        
        // Initialize session stats
        session_stats = SessionStatistics() {
            games_played = 0,
            total_lines = 0,
            best_score = 0
        };
        
        setup_file_paths();
        initialize_statistics();
    }
    
    private void setup_file_paths() {
        string config_dir = Path.build_filename(
            Environment.get_home_dir(),
            ".config",
            "five-or-more"
        );
        
        stats_file_path = Path.build_filename(config_dir, "player-statistics.json");
        global_stats_file_path = Path.build_filename(config_dir, "global-statistics.json");
        
        // Ensure config directory exists
        try {
            DirUtils.create_with_parents(config_dir, 0755);
        } catch (Error e) {
            warning("Failed to create config directory: %s", e.message);
        }
    }
    
    private void initialize_statistics() {
        // Initialize line statistics for lengths 5-12
        for (int i = 5; i <= 12; i++) {
            lines_by_length.set(i, 0);
            session_lines_by_length.set(i, 0);
        }
        
        total_games_played = 0;
        user_best_score = 0;
        global_best_score = 0;
    }
    
    public void load_from_settings() {
        load_user_statistics();
        load_global_statistics();
    }
    
    private void load_user_statistics() {
        try {
            if (!FileUtils.test(stats_file_path, FileTest.EXISTS)) {
                return; // No existing stats file
            }
            
            string content;
            FileUtils.get_contents(stats_file_path, out content);
            
            var parser = new Json.Parser();
            parser.load_from_data(content);
            
            var root = parser.get_root().get_object();
            
            // Load total games played
            if (root.has_member("total_games_played")) {
                total_games_played = (int)root.get_int_member("total_games_played");
            }
            
            // Load user best score
            if (root.has_member("user_best_score")) {
                user_best_score = (int)root.get_int_member("user_best_score");
            }
            
            // Load line statistics
            if (root.has_member("lines_by_length")) {
                var lines_obj = root.get_object_member("lines_by_length");
                for (int length = 5; length <= 12; length++) {
                    string key = length.to_string();
                    if (lines_obj.has_member(key)) {
                        lines_by_length.set(length, (int)lines_obj.get_int_member(key));
                    }
                }
            }
            
        } catch (Error e) {
            warning("Failed to load user statistics: %s", e.message);
        }
    }
    
    private void load_global_statistics() {
        try {
            if (!FileUtils.test(global_stats_file_path, FileTest.EXISTS)) {
                global_best_score = user_best_score; // Use user score as initial global
                save_global_statistics();
                return;
            }
            
            string content;
            FileUtils.get_contents(global_stats_file_path, out content);
            
            var parser = new Json.Parser();
            parser.load_from_data(content);
            
            var root = parser.get_root().get_object();
            
            if (root.has_member("global_best_score")) {
                global_best_score = (int)root.get_int_member("global_best_score");
            }
            
        } catch (Error e) {
            warning("Failed to load global statistics: %s", e.message);
            global_best_score = user_best_score;
        }
    }
    
    public void save_statistics() {
        save_user_statistics();
        save_global_statistics();
    }
    
    private void save_user_statistics() {
        try {
            var builder = new Json.Builder();
            builder.begin_object();
            
            builder.set_member_name("total_games_played");
            builder.add_int_value(total_games_played);
            
            builder.set_member_name("user_best_score");
            builder.add_int_value(user_best_score);
            
            builder.set_member_name("lines_by_length");
            builder.begin_object();
            for (int length = 5; length <= 12; length++) {
                builder.set_member_name(length.to_string());
                int count = lines_by_length.has_key(length) ? lines_by_length.get(length) : 0;
                builder.add_int_value(count);
            }
            builder.end_object();
            
            builder.end_object();
            
            var generator = new Json.Generator();
            generator.set_root(builder.get_root());
            generator.pretty = true;
            
            generator.to_file(stats_file_path);
            
        } catch (Error e) {
            warning("Failed to save user statistics: %s", e.message);
        }
    }
    
    private void save_global_statistics() {
        try {
            var builder = new Json.Builder();
            builder.begin_object();
            
            builder.set_member_name("global_best_score");
            builder.add_int_value(global_best_score);
            
            builder.end_object();
            
            var generator = new Json.Generator();
            generator.set_root(builder.get_root());
            generator.pretty = true;
            
            generator.to_file(global_stats_file_path);
            
        } catch (Error e) {
            warning("Failed to save global statistics: %s", e.message);
        }
    }
    
    public void record_game_completion(int final_score) {
        total_games_played++;
        session_stats.games_played++;
        
        if (final_score > user_best_score) {
            user_best_score = final_score;
        }
        
        if (final_score > global_best_score) {
            global_best_score = final_score;
        }
        
        if (final_score > session_stats.best_score) {
            session_stats.best_score = final_score;
        }
        
        save_statistics();
    }
    
    public void record_line_achievement(int line_length) {
        if (line_length >= 5 && line_length <= 12) {
            // Update overall persistent statistics
            int current_count = lines_by_length.get(line_length);
            lines_by_length.set(line_length, current_count + 1);
            
            // Update session statistics
            int session_count = session_lines_by_length.get(line_length);
            session_lines_by_length.set(line_length, session_count + 1);
            session_stats.total_lines++;
            
            save_statistics();
        }
    }
    
    public HashMap<int, int> get_lines_statistics() {
        return lines_by_length;
    }
    
    public HashMap<int, int> get_session_lines_statistics() {
        return session_lines_by_length;
    }
    
    public int get_total_games_played() {
        return total_games_played;
    }
    
    public int get_user_best_score() {
        return user_best_score;
    }
    
    public int get_global_best_score() {
        return global_best_score;
    }
    
    public SessionStatistics get_session_statistics() {
        return session_stats;
    }
    
    /**
     * Reset session statistics (called when a new game starts)
     */
    public void reset_session_statistics() {
        session_stats = SessionStatistics() {
            games_played = 0,
            total_lines = 0,
            best_score = 0
        };
        
        // Reset session line achievements
        for (int i = 5; i <= 12; i++) {
            session_lines_by_length.set(i, 0);
        }
    }
    
    /**
     * Get formatted statistics summary
     */
    public string get_statistics_summary() {
        var summary = new StringBuilder();
        
        summary.append("=== Player Statistics ===\n");
        summary.append(@"Total Games: $total_games_played\n");
        summary.append(@"Best Score: $user_best_score\n");
        summary.append(@"Global Best: $global_best_score\n\n");
        
        summary.append("Lines Achieved:\n");
        for (int length = 5; length <= 12; length++) {
            int count = lines_by_length.has_key(length) ? lines_by_length.get(length) : 0;
            if (count > 0) {
                summary.append(@"  $length-line: $count times\n");
            }
        }
        
        summary.append("\nSession Statistics:\n");
        summary.append(@"  Games: $(session_stats.games_played)\n");
        summary.append(@"  Lines: $(session_stats.total_lines)\n");
        summary.append(@"  Best: $(session_stats.best_score)\n");
        
        return summary.str;
    }
}