/*
 * Tabbed Sidebar for Five or More
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
 * Tabbed sidebar containing Statistics and Development tabs
 */
internal class TabbedSidebar : Box {
    private Game? game;
    private GLib.Settings settings;
    
    // UI Components
    private Notebook notebook;
    private StatisticsPanel statistics_panel;
    private GameInfoPanel development_panel;
    
    // Tab management
    private bool development_tab_enabled = false;
    
    public TabbedSidebar(GLib.Settings settings) {
        Object(orientation: Orientation.VERTICAL, spacing: 0);
        
        this.settings = settings;
        this.development_tab_enabled = get_development_tab_enabled();
        
        setup_ui();
        load_settings();
    }
    
    private void setup_ui() {
        // Create notebook for tabs
        notebook = new Notebook();
        notebook.set_tab_pos(PositionType.TOP);
        notebook.set_scrollable(false);
        notebook.set_show_border(false);
        
        // Create statistics panel (always enabled)
        statistics_panel = new StatisticsPanel(settings);
        var stats_label = new Label(_("Statistics"));
        notebook.append_page(statistics_panel, stats_label);
        
        // Create development panel (conditionally enabled)
        if (development_tab_enabled) {
            development_panel = new GameInfoPanel();
            var dev_label = new Label(_("Development"));
            notebook.append_page(development_panel, dev_label);
        }
        
        pack_start(notebook, true, true, 0);
        
        // Set initial tab
        notebook.set_current_page(0); // Always start with Statistics tab
    }
    
    private void load_settings() {
        // Load any saved tab preferences
        try {
            var saved_tab = settings.get_int("sidebar-active-tab");
            if (saved_tab >= 0 && saved_tab < notebook.get_n_pages()) {
                notebook.set_current_page(saved_tab);
            }
        } catch (Error e) {
            // Use default tab (Statistics)
        }
        
        // Connect to tab changes to save preference
        notebook.switch_page.connect((page, page_num) => {
            try {
                settings.set_int("sidebar-active-tab", (int)page_num);
            } catch (Error e) {
                warning("Failed to save sidebar tab preference: %s", e.message);
            }
        });
    }
    
    private bool get_development_tab_enabled() {
        // Check if development tab should be enabled
        // Can be controlled by environment variable or settings
        var env_dev = Environment.get_variable("FIVE_OR_MORE_DEV_TAB");
        if (env_dev != null && env_dev.down() == "true") {
            return true;
        }
        
        // Check settings
        try {
            return settings.get_boolean("enable-development-tab");
        } catch (Error e) {
            return false; // Default to disabled
        }
    }
    
    public void set_game(Game? game) {
        this.game = game;
        
        // Update both panels
        statistics_panel.set_game(game);
        
        if (development_panel != null) {
            development_panel.set_game(game);
        }
    }
    
    public void on_game_state_changed() {
        statistics_panel.on_game_state_changed();
        
        if (development_panel != null) {
            development_panel.on_game_state_changed();
        }
    }
    
    public void on_board_clicked(int row, int col) {
        // Forward to development panel if it exists
        if (development_panel != null) {
            development_panel.on_board_clicked(row, col);
        }
    }
    
    public void on_line_detection_performed(int row, int col, bool had_lines) {
        // Forward to both panels
        statistics_panel.on_line_detection_performed(row, col, had_lines);
        
        if (development_panel != null) {
            development_panel.on_line_detection_performed(row, col, had_lines);
        }
    }
    
    /**
     * Called when lines are detected with cell count information
     */
    public void on_line_detection_with_count(int row, int col, bool had_lines, int cells_removed) {
        // Forward to statistics panel for line achievement tracking
        statistics_panel.on_line_detection_with_count(row, col, had_lines, cells_removed);
        
        // Also forward to development panel if it exists
        if (development_panel != null) {
            development_panel.on_line_detection_performed(row, col, had_lines);
        }
    }
    
    /**
     * Called when lines are cleared with detailed cell information
     */
    public void on_lines_cleared_with_info(Gee.HashSet<Cell> removed_cells) {
        statistics_panel.on_lines_cleared_with_info(removed_cells);
    }
    
    /**
     * Called when a game ends to update final statistics
     */
    public void on_game_ended(int final_score) {
        statistics_panel.on_game_ended(final_score);
    }
    
    /**
     * Called when line lengths are detected for accurate statistics tracking
     */
    public void on_line_lengths_detected(Gee.ArrayList<int> line_lengths) {
        // Forward to statistics panel for tracking
        statistics_panel.on_line_lengths_detected(line_lengths);
    }
    
    /**
     * Called when a new game starts to reset session statistics
     */
    public void on_new_game_started() {
        statistics_panel.on_new_game_started();
    }
    
    public void validate_coordinate_mapping(int visual_x, int visual_y, int logical_row, int logical_col) {
        // Forward to development panel if it exists
        if (development_panel != null) {
            development_panel.validate_coordinate_mapping(visual_x, visual_y, logical_row, logical_col);
        }
    }
    
    /**
     * Enable or disable the development tab
     */
    public void set_development_tab_enabled(bool enabled) {
        if (enabled == development_tab_enabled) {
            return; // No change needed
        }
        
        development_tab_enabled = enabled;
        
        if (enabled && development_panel == null) {
            // Add development tab
            development_panel = new GameInfoPanel();
            if (game != null) {
                development_panel.set_game(game);
            }
            
            var dev_label = new Label(_("Development"));
            notebook.append_page(development_panel, dev_label);
            development_panel.show_all();
        } else if (!enabled && development_panel != null) {
            // Remove development tab
            var page_num = notebook.page_num(development_panel);
            if (page_num >= 0) {
                notebook.remove_page(page_num);
            }
            development_panel = null;
        }
        
        // Save setting
        try {
            settings.set_boolean("enable-development-tab", enabled);
        } catch (Error e) {
            warning("Failed to save development tab setting: %s", e.message);
        }
    }
    
    public bool get_development_tab_enabled_status() {
        return development_tab_enabled;
    }
}