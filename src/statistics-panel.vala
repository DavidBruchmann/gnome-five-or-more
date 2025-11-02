/*
 * Statistics Panel for Five or More
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

using Gtk;

/**
 * Statistics panel showing user gameplay statistics and achievements
 */
internal class StatisticsPanel : ScrolledWindow {
    private Game? game;
    private GLib.Settings settings;
    
    // UI Components
    private Box main_content;
    private Label current_game_label;
    private Label board_size_label;
    private Label difficulty_label;
    private Label combo_mode_label;
    private Label lines_stats_label;
    private Label games_played_label;
    private Label user_best_score_label;
    private Label global_best_score_label;
    private Label session_stats_label;
    private Label overall_lines_label;
    
    // Statistics tracking
    private PlayerStatistics player_stats;
    
    // Real-time update timer
    private uint update_timer_id = 0;
    
    public StatisticsPanel(GLib.Settings settings) {
        this.settings = settings;
        this.player_stats = new PlayerStatistics(settings);
        
        setup_ui();
        load_statistics();
    }
    
    private void setup_ui() {
        set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        set_min_content_width(300);
        
        main_content = new Box(Orientation.VERTICAL, 12);
        main_content.margin = 12;
        
        // Current Game Section
        add_section_header(_("Current Game"));
        
        current_game_label = new Label("");
        current_game_label.set_xalign(0);
        current_game_label.set_line_wrap(true);
        main_content.pack_start(current_game_label, false, false, 0);
        
        board_size_label = new Label("");
        board_size_label.set_xalign(0);
        main_content.pack_start(board_size_label, false, false, 0);
        
        difficulty_label = new Label("");
        difficulty_label.set_xalign(0);
        main_content.pack_start(difficulty_label, false, false, 0);
        
        combo_mode_label = new Label("");
        combo_mode_label.set_xalign(0);
        main_content.pack_start(combo_mode_label, false, false, 0);
        
        add_separator();
        
        // Current Game Lines Achievement Section
        add_section_header(_("Lines This Game"));
        
        lines_stats_label = new Label("");
        lines_stats_label.set_xalign(0);
        lines_stats_label.set_line_wrap(true);
        main_content.pack_start(lines_stats_label, false, false, 0);
        
        add_separator();
        
        // Session Statistics
        add_section_header(_("Session Statistics"));
        
        session_stats_label = new Label("");
        session_stats_label.set_xalign(0);
        session_stats_label.set_line_wrap(true);
        main_content.pack_start(session_stats_label, false, false, 0);
        
        add_separator();
        
        // Overall Statistics Section
        add_section_header(_("Overall Statistics"));
        
        games_played_label = new Label("");
        games_played_label.set_xalign(0);
        main_content.pack_start(games_played_label, false, false, 0);
        
        user_best_score_label = new Label("");
        user_best_score_label.set_xalign(0);
        main_content.pack_start(user_best_score_label, false, false, 0);
        
        global_best_score_label = new Label("");
        global_best_score_label.set_xalign(0);
        main_content.pack_start(global_best_score_label, false, false, 0);
        
        add_separator();
        
        // Overall Line Achievements Section
        add_section_header(_("All-Time Line Achievements"));
        
        overall_lines_label = new Label("");
        overall_lines_label.set_xalign(0);
        overall_lines_label.set_line_wrap(true);
        main_content.pack_start(overall_lines_label, false, false, 0);
        
        add(main_content);
        
        // Update display initially
        update_display();
        
        // Set up real-time updates every 5 seconds
        update_timer_id = Timeout.add_seconds(5, () => {
            update_display();
            return Source.CONTINUE;
        });
    }
    
    private void add_section_header(string title) {
        var header = new Label(@"<b>$title</b>");
        header.set_use_markup(true);
        header.set_xalign(0);
        header.margin_top = 6;
        main_content.pack_start(header, false, false, 0);
    }
    
    private void add_separator() {
        var separator = new Separator(Orientation.HORIZONTAL);
        separator.margin_top = 6;
        separator.margin_bottom = 6;
        main_content.pack_start(separator, false, false, 0);
    }
    
    private void load_statistics() {
        player_stats.load_from_settings();
    }
    
    public void set_game(Game? game) {
        this.game = game;
        update_display();
    }
    
    public void on_game_state_changed() {
        update_display();
    }
    
    public void on_line_detection_performed(int row, int col, bool had_lines) {
        if (had_lines && game != null) {
            // This will be called when lines are detected
            // We'll update statistics in the next update cycle
            Idle.add(() => {
                update_display();
                return Source.REMOVE;
            });
        }
    }
    
    /**
     * Called when lines are detected with cell count information
     */
    public void on_line_detection_with_count(int row, int col, bool had_lines, int cells_removed) {
        if (had_lines && cells_removed >= 5) {
            // Estimate line lengths based on cells removed
            // This is a heuristic - we'll improve this with better line detection later
            var estimated_lengths = estimate_line_lengths_from_cell_count(cells_removed);
            
            // Record each estimated line length
            foreach (int length in estimated_lengths) {
                player_stats.record_line_achievement(length);
            }
            
            // Update display
            Idle.add(() => {
                update_display();
                return Source.REMOVE;
            });
        }
    }
    
    /**
     * Estimate line lengths from total cell count
     * This is a heuristic until we implement proper line length detection
     */
    private Gee.ArrayList<int> estimate_line_lengths_from_cell_count(int total_cells) {
        var lengths = new Gee.ArrayList<int>();
        
        // Simple heuristic: try to break down into reasonable line lengths
        if (total_cells >= 5 && total_cells <= 12) {
            // Single line
            lengths.add(total_cells);
        } else if (total_cells > 12) {
            // Multiple lines - estimate based on common patterns
            int remaining = total_cells;
            while (remaining >= 5) {
                if (remaining >= 10) {
                    lengths.add(7); // Common line length
                    remaining -= 7;
                } else {
                    lengths.add(remaining);
                    remaining = 0;
                }
            }
        }
        
        return lengths;
    }
    
    /**
     * Called when lines are cleared with specific line information
     */
    public void on_lines_cleared_with_info(Gee.HashSet<Cell> removed_cells) {
        if (removed_cells.size == 0) return;
        
        // Analyze the removed cells to determine line lengths
        var line_lengths = analyze_removed_cells_for_line_lengths(removed_cells);
        
        // Record each line length achievement
        foreach (int length in line_lengths) {
            player_stats.record_line_achievement(length);
        }
        
        // Update display
        Idle.add(() => {
            update_display();
            return Source.REMOVE;
        });
    }
    
    /**
     * Analyze removed cells to determine individual line lengths
     */
    private Gee.ArrayList<int> analyze_removed_cells_for_line_lengths(Gee.HashSet<Cell> removed_cells) {
        var line_lengths = new Gee.ArrayList<int>();
        
        // For now, use a simple heuristic based on total cells removed
        // This is not perfect but will provide some statistics
        int total_cells = removed_cells.size;
        
        if (total_cells >= 5) {
            // Assume it's a single line of the total length
            // TODO: Implement proper line analysis to detect multiple lines
            line_lengths.add(total_cells);
        }
        
        return line_lengths;
    }
    
    private void update_display() {
        update_current_game_info();
        update_lines_statistics();
        update_session_statistics();
        update_overall_statistics();
        update_overall_lines_statistics();
    }
    
    private void update_current_game_info() {
        if (game == null) {
            current_game_label.set_text(_("No game active"));
            board_size_label.set_text("");
            difficulty_label.set_text("");
            combo_mode_label.set_text("");
            return;
        }
        
        // Current score
        current_game_label.set_text(_("Current Score: %d").printf(game.score));
        
        // Board size
        string size_name = get_board_size_name();
        board_size_label.set_text(_("Board Size: %s").printf(size_name));
        
        // Difficulty
        string difficulty_name = get_difficulty_name();
        difficulty_label.set_text(_("Difficulty: %s").printf(difficulty_name));
        
        // Combo mode status
        var constants = get_game_constants();
        string combo_status = constants.ENABLE_COMPOSITE_LINES ? _("Enabled") : _("Disabled");
        combo_mode_label.set_text(_("Combo Play: %s").printf(combo_status));
    }
    
    private void update_lines_statistics() {
        // Show session line achievements (reset each game)
        var stats = player_stats.get_session_lines_statistics();
        var text = new StringBuilder();
        
        for (int length = 5; length <= 12; length++) {
            int count = stats.has_key(length) ? stats.get(length) : 0;
            if (count > 0) {
                text.append(_("%d-line: %d times\n").printf(length, count));
            }
        }
        
        if (text.len == 0) {
            text.append(_("No lines achieved yet"));
        }
        
        lines_stats_label.set_text(text.str.chomp());
    }
    
    private void update_session_statistics() {
        var session_stats = player_stats.get_session_statistics();
        var text = new StringBuilder();
        
        text.append(_("Games this session: %d\n").printf(session_stats.games_played));
        text.append(_("Lines this session: %d\n").printf(session_stats.total_lines));
        text.append(_("Best score this session: %d").printf(session_stats.best_score));
        
        session_stats_label.set_text(text.str);
    }
    
    private void update_overall_statistics() {
        var total_games = player_stats.get_total_games_played();
        var user_best = player_stats.get_user_best_score();
        var global_best = player_stats.get_global_best_score();
        
        games_played_label.set_text(_("Total Games Played: %d").printf(total_games));
        user_best_score_label.set_text(_("Your Best Score: %d").printf(user_best));
        global_best_score_label.set_text(_("Global Best Score: %d").printf(global_best));
    }
    
    private void update_overall_lines_statistics() {
        // Show persistent line achievements (across all games)
        var stats = player_stats.get_lines_statistics();
        var text = new StringBuilder();
        
        for (int length = 5; length <= 12; length++) {
            int count = stats.has_key(length) ? stats.get(length) : 0;
            if (count > 0) {
                text.append(_("%d-line: %d times\n").printf(length, count));
            }
        }
        
        if (text.len == 0) {
            text.append(_("No lines achieved yet"));
        }
        
        overall_lines_label.set_text(text.str.chomp());
    }
    
    private string get_board_size_name() {
        if (game == null) return _("Unknown");
        
        // Determine board size based on dimensions
        int cols = game.n_cols;
        int rows = game.n_rows;
        
        if (cols == 7 && rows == 7) return _("Small");
        if (cols == 9 && rows == 9) return _("Medium");
        if (cols == 20 && rows == 15) return _("Large");
        
        return _("Custom (%dx%d)").printf(cols, rows);
    }
    
    private string get_difficulty_name() {
        if (game == null) return _("Unknown");
        
        // Get difficulty from settings
        try {
            string difficulty = settings.get_string("difficulty");
            switch (difficulty) {
                case "easy": return _("Easy");
                case "normal": return _("Normal");
                case "hard": return _("Hard");
                default: return _("Custom");
            }
        } catch (Error e) {
            return _("Unknown");
        }
    }
    
    /**
     * Called when a game ends to update statistics
     */
    public void on_game_ended(int final_score) {
        player_stats.record_game_completion(final_score);
        update_display();
    }
    
    /**
     * Called when lines are cleared to update line statistics
     */
    public void on_lines_cleared(Gee.ArrayList<int> line_lengths) {
        foreach (int length in line_lengths) {
            player_stats.record_line_achievement(length);
        }
        update_display();
    }
    
    /**
     * Called when line lengths are detected for accurate statistics tracking
     */
    public void on_line_lengths_detected(Gee.ArrayList<int> line_lengths) {
        // Record each line length achievement
        foreach (int length in line_lengths) {
            player_stats.record_line_achievement(length);
        }
        
        // Update display immediately
        Idle.add(() => {
            update_display();
            return Source.REMOVE;
        });
    }
    
    /**
     * Called when a new game starts to reset session statistics
     */
    public void on_new_game_started() {
        player_stats.reset_session_statistics();
        update_display();
    }
    
    ~StatisticsPanel() {
        if (update_timer_id != 0) {
            Source.remove(update_timer_id);
            update_timer_id = 0;
        }
    }
}