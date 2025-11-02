/*
 * Line Detection Debug Panel for Five or More
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
 * Game information side panel with line detection analysis capabilities
 */
internal class GameInfoPanel : Box {
    private Game? game;
    private Board? board;
    private Cell[,]? grid;
    
    // UI Components
    private ScrolledWindow scrolled_window;
    private Box main_content;
    private Label coordinate_info_label;
    private Label board_dimensions_label;
    private Label selected_position_label;
    private Label traditional_detection_label;
    private Label composite_detection_label;
    private Label phantom_warnings_label;
    private Label coordinate_validation_label;
    private TextView debug_log_view;
    private TextBuffer debug_log_buffer;
    private Button clear_log_button;
    private Button export_debug_button;
    private CheckButton enable_real_time_checkbox;
    
    // Debug state
    private int selected_row = -1;
    private int selected_col = -1;
    private bool real_time_enabled = true;
    private Gee.ArrayList<string> debug_messages;
    
    construct {
        orientation = Orientation.VERTICAL;
        spacing = 6;
        margin = 12;
        set_size_request(get_game_constants().DEBUG_PANEL_WIDTH, -1);
        
        debug_messages = new Gee.ArrayList<string>();
        
        setup_ui();
        setup_signals();
    }
    
    private void setup_ui() {
        // Header
        var header_label = new Label("Game Information");
        header_label.get_style_context().add_class("heading");
        header_label.set_markup("<b>Game Information</b>");
        pack_start(header_label, false, false, 0);
        
        // Create scrolled window for main content
        scrolled_window = new ScrolledWindow(null, null);
        scrolled_window.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        scrolled_window.set_vexpand(true);
        pack_start(scrolled_window, true, true, 0);
        
        main_content = new Box(Orientation.VERTICAL, 6);
        scrolled_window.add(main_content);
        
        // Real-time monitoring toggle
        enable_real_time_checkbox = new CheckButton.with_label("Enable Live Updates");
        enable_real_time_checkbox.active = real_time_enabled;
        main_content.pack_start(enable_real_time_checkbox, false, false, 0);
        
        // Game Information
        setup_game_info_section();
        
        // Board Information
        setup_board_info_section();
        
        // Selected Position
        setup_position_info_section();
        
        // Line Analysis
        setup_line_analysis_section();
        
        // System Alerts
        setup_alerts_section();
        
        // Technical Details
        setup_technical_section();
        
        // Activity Log
        setup_activity_log_section();
        
        // Control Buttons
        setup_control_buttons();
        
        show_all();
    }
    
    private void setup_game_info_section() {
        var frame = create_section_frame("Game Settings");
        coordinate_info_label = new Label("No game loaded");
        coordinate_info_label.set_line_wrap(true);
        coordinate_info_label.set_xalign(0);
        frame.add(coordinate_info_label);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_board_info_section() {
        var frame = create_section_frame("Board Information");
        board_dimensions_label = new Label("No board loaded");
        board_dimensions_label.set_line_wrap(true);
        board_dimensions_label.set_xalign(0);
        frame.add(board_dimensions_label);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_position_info_section() {
        var frame = create_section_frame("Position Details");
        selected_position_label = new Label("Click on board to inspect position");
        selected_position_label.set_line_wrap(true);
        selected_position_label.set_xalign(0);
        frame.add(selected_position_label);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_line_analysis_section() {
        var frame = create_section_frame("Line Analysis");
        var detection_box = new Box(Orientation.VERTICAL, 3);
        
        traditional_detection_label = new Label("Classic Detection: No data");
        traditional_detection_label.set_line_wrap(true);
        traditional_detection_label.set_xalign(0);
        detection_box.pack_start(traditional_detection_label, false, false, 0);
        
        composite_detection_label = new Label("Advanced Detection: No data");
        composite_detection_label.set_line_wrap(true);
        composite_detection_label.set_xalign(0);
        detection_box.pack_start(composite_detection_label, false, false, 0);
        
        frame.add(detection_box);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_alerts_section() {
        var frame = create_section_frame("System Alerts");
        phantom_warnings_label = new Label("No alerts");
        phantom_warnings_label.set_line_wrap(true);
        phantom_warnings_label.set_xalign(0);
        frame.add(phantom_warnings_label);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_technical_section() {
        var frame = create_section_frame("Technical Details");
        coordinate_validation_label = new Label("No technical data");
        coordinate_validation_label.set_line_wrap(true);
        coordinate_validation_label.set_xalign(0);
        frame.add(coordinate_validation_label);
        main_content.pack_start(frame, false, false, 0);
    }
    
    private void setup_activity_log_section() {
        var frame = create_section_frame("Activity Log");
        
        debug_log_view = new TextView();
        debug_log_view.set_editable(false);
        debug_log_view.set_cursor_visible(false);
        debug_log_view.set_wrap_mode(WrapMode.WORD);
        debug_log_buffer = debug_log_view.get_buffer();
        
        var log_scrolled = new ScrolledWindow(null, null);
        log_scrolled.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        log_scrolled.set_size_request(-1, get_game_constants().DEBUG_LOG_HEIGHT);
        log_scrolled.add(debug_log_view);
        
        frame.add(log_scrolled);
        main_content.pack_start(frame, true, true, 0);
    }
    
    private void setup_control_buttons() {
        var button_box = new Box(Orientation.HORIZONTAL, 6);
        
        clear_log_button = new Button.with_label("Clear Log");
        clear_log_button.clicked.connect(clear_activity_log);
        button_box.pack_start(clear_log_button, true, true, 0);
        
        export_debug_button = new Button.with_label("Export Info");
        export_debug_button.clicked.connect(export_game_info);
        button_box.pack_start(export_debug_button, true, true, 0);
        
        pack_start(button_box, false, false, 0);
    }
    
    private Frame create_section_frame(string title) {
        var frame = new Frame(title);
        frame.set_label_align(0.02f, 0.5f);
        frame.get_label_widget().get_style_context().add_class("dim-label");
        frame.set_margin_top(3);
        frame.set_margin_bottom(3);
        return frame;
    }
    
    private void setup_signals() {
        enable_real_time_checkbox.toggled.connect(() => {
            real_time_enabled = enable_real_time_checkbox.active;
            log_activity_message(@"Live updates $(real_time_enabled ? "enabled" : "disabled")");
            if (real_time_enabled) {
                update_all_displays();
            }
        });
    }
    
    /**
     * Set the game instance for debugging
     */
    internal void set_game(Game? game) {
        this.game = game;
        if (game != null) {
            this.board = game.board;
            if (board != null) {
                this.grid = board.get_grid();
            }
        }
        update_all_displays();
        log_activity_message("Game instance updated");
    }
    
    /**
     * Update position selection for debugging
     */
    internal void set_selected_position(int row, int col) {
        selected_row = row;
        selected_col = col;
        
        // Log detailed coordinate mapping information
        var coord_info = get_detailed_coordinate_info(row, col);
        log_activity_message(@"Position selected: $coord_info");
        
        if (real_time_enabled) {
            update_selected_position_display();
            update_line_detection_display();
            update_coordinate_validation_display();
            check_phantom_lines();
        }
    }
    
    /**
     * Get detailed coordinate information for logging
     */
    private string get_detailed_coordinate_info(int row, int col) {
        var info = new StringBuilder();
        info.append(@"Logical($row,$col)");
        
        if (board != null) {
            info.append(@" on $(board.n_rows)×$(board.n_cols) board");
            
            // Add position type information
            bool is_corner = (row == 0 || row == board.n_rows - 1) && (col == 0 || col == board.n_cols - 1);
            bool is_edge = !is_corner && (row == 0 || row == board.n_rows - 1 || col == 0 || col == board.n_cols - 1);
            
            if (is_corner) info.append(" [CORNER]");
            else if (is_edge) info.append(" [EDGE]");
            else info.append(" [CENTER]");
        }
        
        // Add validation status
        bool valid = is_valid_grid_position(row, col);
        info.append(valid ? " ✓" : " ✗");
        
        return info.str;
    }
    
    /**
     * Trigger manual update of all displays
     */
    internal void update_all_displays() {
        update_coordinate_info_display();
        update_board_dimensions_display();
        update_selected_position_display();
        update_line_detection_display();
        update_coordinate_validation_display();
        check_phantom_lines();
    }
    
    private void update_coordinate_info_display() {
        if (game == null) {
            coordinate_info_label.set_text("No game loaded");
            return;
        }
        
        var info = new StringBuilder();
        info.append(@"Game Size: $(game.get_board_size())\n");
        info.append(@"Difficulty: $(game.get_difficulty_name())\n");
        
        if (game.get_board_size() > 0 && game.get_board_size() < Game.game_difficulty.length) {
            var difficulty = Game.game_difficulty[game.get_board_size()];
            info.append(@"GameDifficulty Array: [$(difficulty.n_cols), $(difficulty.n_rows), $(difficulty.n_types), $(difficulty.n_next_pieces)]\n");
            info.append("Note: Array format is [n_cols, n_rows, n_types, n_next_pieces]");
        }
        
        coordinate_info_label.set_text(info.str);
    }
    
    private void update_board_dimensions_display() {
        if (board == null || grid == null) {
            board_dimensions_label.set_text("No board loaded");
            return;
        }
        
        var info = new StringBuilder();
        info.append(@"Board Rows: $(board.n_rows)\n");
        info.append(@"Board Cols: $(board.n_cols)\n");
        info.append(@"Grid Array Dimensions: [$(grid.length[0]), $(grid.length[1])]\n");
        info.append(@"Total Cells: $(board.n_rows * board.n_cols)\n");
        info.append(@"Filled Cells: $(game != null ? game.n_filled_cells : 0)");
        
        // Check for coordinate consistency
        bool dimensions_consistent = (board.n_rows == grid.length[0] && board.n_cols == grid.length[1]);
        if (!dimensions_consistent) {
            info.append("\n⚠️ DIMENSION MISMATCH DETECTED!");
        }
        
        board_dimensions_label.set_text(info.str);
    }
    
    private void update_selected_position_display() {
        if (selected_row == -1 || selected_col == -1) {
            selected_position_label.set_text("Click on board to select position");
            return;
        }
        
        var info = new StringBuilder();
        info.append(@"🎯 SELECTED POSITION\n");
        info.append(@"Logical: ($selected_row, $selected_col)\n");
        
        // Show visual to logical coordinate mapping
        if (board != null) {
            info.append(@"Visual Click → Logical: ($selected_col, $selected_row) → ($selected_row, $selected_col)\n");
            info.append(@"Board Size: $(board.n_rows)×$(board.n_cols)\n");
        }
        
        if (grid != null && is_valid_grid_position(selected_row, selected_col)) {
            var cell = grid[selected_row, selected_col];
            info.append(@"\n📍 CELL DETAILS\n");
            
            if (cell.piece != null) {
                info.append(@"Piece: Type $(cell.piece.id) (Color ID)\n");
                info.append(@"Piece State: Active\n");
            } else {
                info.append("Piece: Empty Cell\n");
                info.append("Piece State: Available for placement\n");
            }
            
            info.append(@"Cell Object: Row=$(cell.row), Col=$(cell.col)\n");
            
            // Add neighbor analysis
            info.append(@"\n🔍 NEIGHBOR ANALYSIS\n");
            var neighbors = get_neighbor_info(selected_row, selected_col);
            info.append(neighbors);
            
        } else {
            info.append("\n⚠️ INVALID POSITION\n");
            info.append("Status: Out of bounds!\n");
            if (board != null) {
                info.append(@"Valid range: 0-$(board.n_rows-1), 0-$(board.n_cols-1)");
            }
        }
        
        selected_position_label.set_text(info.str);
    }
    
    private void update_line_detection_display() {
        if (selected_row == -1 || selected_col == -1 || grid == null) {
            traditional_detection_label.set_text("Traditional: No position selected");
            composite_detection_label.set_text("Composite: No position selected");
            return;
        }
        
        if (!is_valid_grid_position(selected_row, selected_col)) {
            traditional_detection_label.set_text("Traditional: Invalid position");
            composite_detection_label.set_text("Composite: Invalid position");
            return;
        }
        
        var cell = grid[selected_row, selected_col];
        
        // Traditional line detection with detailed analysis
        var traditional_info = new StringBuilder();
        traditional_info.append(@"🔍 TRADITIONAL DETECTION\n");
        
        if (cell.piece == null) {
            traditional_info.append("No piece at position\n");
        } else {
            var traditional_cells = cell.get_all_directions(grid);
            traditional_info.append(@"Found: $(traditional_cells.size) pieces\n");
            traditional_info.append(@"Required: $(Game.N_MATCH) pieces\n");
            
            if (traditional_cells.size > 0) {
                string status = traditional_cells.size >= Game.N_MATCH ? "✅ VALID LINE" : "⚠️ TOO SHORT";
                traditional_info.append(@"Status: $status\n");
                
                // Show direction analysis
                traditional_info.append("Directions: ");
                var directions_found = analyze_line_directions(selected_row, selected_col, cell.piece.id);
                traditional_info.append(directions_found);
            } else {
                traditional_info.append("Status: No lines detected");
            }
        }
        traditional_detection_label.set_text(traditional_info.str);
        
        // Advanced line detection with detailed analysis
        var composite_info = new StringBuilder();
        composite_info.append(@"🔍 COMPOSITE DETECTION\n");
        
        if (cell.piece == null) {
            composite_info.append("No piece at position\n");
        } else {
            var line_detector = new LineDetector(grid);
            var composite_lines = line_detector.detect_composite_lines(selected_row, selected_col);
            
            composite_info.append(@"Patterns: $(composite_lines.size)\n");
            
            if (composite_lines.size > 0) {
                int total_cells = 0;
                int max_length = 0;
                
                foreach (var line in composite_lines) {
                    total_cells += line.total_length;
                    if (line.total_length > max_length) {
                        max_length = line.total_length;
                    }
                }
                
                composite_info.append(@"Total pieces: $total_cells\n");
                composite_info.append(@"Longest: $max_length pieces\n");
                composite_info.append(@"Status: $(max_length >= Game.N_MATCH ? "✅ VALID" : "⚠️ TOO SHORT")");
            } else {
                composite_info.append("Status: No patterns detected");
            }
        }
        composite_detection_label.set_text(composite_info.str);
    }
    
    private void update_coordinate_validation_display() {
        if (selected_row == -1 || selected_col == -1) {
            coordinate_validation_label.set_text("No position selected for validation");
            return;
        }
        
        var validation = new StringBuilder();
        validation.append(@"🔍 COORDINATE VALIDATION\n");
        validation.append(@"Testing Position: ($selected_row, $selected_col)\n\n");
        
        // Check bounds validation
        bool valid_bounds = is_valid_grid_position(selected_row, selected_col);
        validation.append(@"Grid Bounds: $(valid_bounds ? "✅ VALID" : "❌ INVALID")\n");
        
        if (board != null) {
            bool within_board = (selected_row >= 0 && selected_row < board.n_rows && 
                               selected_col >= 0 && selected_col < board.n_cols);
            validation.append(@"Board Bounds: $(within_board ? "✅ VALID" : "❌ INVALID")\n");
            
            // Show detailed boundary analysis
            validation.append(@"\n📏 BOUNDARY ANALYSIS\n");
            validation.append(@"Row: $selected_row (0 to $(board.n_rows-1))\n");
            validation.append(@"Col: $selected_col (0 to $(board.n_cols-1))\n");
            
            if (selected_row < 0) validation.append("⚠️ Row below minimum\n");
            else if (selected_row >= board.n_rows) validation.append("⚠️ Row above maximum\n");
            
            if (selected_col < 0) validation.append("⚠️ Column below minimum\n");
            else if (selected_col >= board.n_cols) validation.append("⚠️ Column above maximum\n");
        }
        
        if (grid != null) {
            bool within_grid = (selected_row >= 0 && selected_row < grid.length[0] && 
                              selected_col >= 0 && selected_col < grid.length[1]);
            validation.append(@"Array Bounds: $(within_grid ? "✅ VALID" : "❌ INVALID")\n");
            
            // Check for coordinate system consistency
            if (board != null) {
                bool dimensions_match = (board.n_rows == grid.length[0] && board.n_cols == grid.length[1]);
                validation.append(@"Dimension Sync: $(dimensions_match ? "✅ CONSISTENT" : "❌ MISMATCH")\n");
                
                if (!dimensions_match) {
                    validation.append(@"Board: $(board.n_rows)×$(board.n_cols)\n");
                    validation.append(@"Grid: $(grid.length[0])×$(grid.length[1])\n");
                }
            }
        }
        
        // Add coordinate mapping validation
        validation.append(@"\n🗺️ COORDINATE MAPPING\n");
        validation.append(@"Visual → Logical: ($selected_col, $selected_row) → ($selected_row, $selected_col)\n");
        validation.append("Mapping: (x,y) → (row,col)\n");
        
        coordinate_validation_label.set_text(validation.str);
    }
    
    private void check_phantom_lines() {
        if (selected_row == -1 || selected_col == -1 || grid == null) {
            phantom_warnings_label.set_text("No warnings");
            return;
        }
        
        if (!is_valid_grid_position(selected_row, selected_col)) {
            phantom_warnings_label.set_text("Invalid position selected");
            return;
        }
        
        var warnings = new StringBuilder();
        var cell = grid[selected_row, selected_col];
        
        warnings.append(@"🚨 PHANTOM LINE ANALYSIS\n");
        
        if (cell.piece == null) {
            warnings.append("No piece at position - safe\n");
            phantom_warnings_label.set_text(warnings.str);
            return;
        }
        
        // Check for potential phantom lines by examining line detection logic
        var traditional_cells = cell.get_all_directions(grid);
        var line_detector = new LineDetector(grid);
        var composite_lines = line_detector.detect_composite_lines(selected_row, selected_col);
        
        bool has_warnings = false;
        int warning_count = 0;
        
        // Check if traditional detection would remove fewer than required pieces
        if (traditional_cells.size > 0 && traditional_cells.size < Game.N_MATCH) {
            warnings.append(@"⚠️ Short line: $(traditional_cells.size)/$(Game.N_MATCH) pieces\n");
            has_warnings = true;
            warning_count++;
        }
        
        // Check for coordinate boundary issues
        if (board != null) {
            if (selected_row >= board.n_rows || selected_col >= board.n_cols) {
                warnings.append("⚠️ Position exceeds board bounds\n");
                has_warnings = true;
                warning_count++;
            }
            
            // Check for edge cases that might cause phantom detection
            bool near_edge = (selected_row == 0 || selected_row == board.n_rows - 1 || 
                            selected_col == 0 || selected_col == board.n_cols - 1);
            if (near_edge && traditional_cells.size > 0) {
                warnings.append("ℹ️ Edge position - verify boundary logic\n");
            }
        }
        
        // Analyze continuity issues
        if (traditional_cells.size > 0) {
            var continuity_issues = check_line_continuity(selected_row, selected_col, cell.piece.id);
            if (continuity_issues.length > 0) {
                warnings.append(@"⚠️ Continuity gaps: $continuity_issues\n");
                has_warnings = true;
                warning_count++;
            }
        }
        
        // Check for endpoint matching without full continuity
        if (composite_lines.size > 0) {
            foreach (var line in composite_lines) {
                if (line.segments.size > 1) {
                    warnings.append(@"ℹ️ Multi-segment pattern: $(line.segments.size) parts\n");
                    
                    // Check if this could be a phantom line
                    if (line.total_length >= Game.N_MATCH) {
                        warnings.append("⚠️ Potential phantom: endpoints match but gaps exist\n");
                        has_warnings = true;
                        warning_count++;
                    }
                }
            }
        }
        
        // Summary
        if (!has_warnings) {
            warnings.append("✅ No phantom line risks detected");
        } else {
            warnings.append(@"\n📊 SUMMARY: $warning_count warnings found");
        }
        
        phantom_warnings_label.set_text(warnings.str);
    }
    
    private string check_line_continuity(int row, int col, int piece_type) {
        if (grid == null) return "";
        
        var issues = new Gee.ArrayList<string>();
        var line_directions = new int[,] {
            {0, 1},   // Horizontal
            {1, 0},   // Vertical  
            {1, 1},   // Diagonal \
            {1, -1}   // Diagonal /
        };
        
        string[] direction_names = {"H", "V", "\\", "/"};
        
        for (int d = 0; d < line_directions.length[0]; d++) {
            int dr = line_directions[d,0];
            int dc = line_directions[d,1];
            
            // Check for gaps in both directions
            var gaps = new Gee.ArrayList<string>();
            
            // Check forward direction
            for (int i = 1; i <= Game.N_MATCH; i++) {
                int nr = row + i * dr;
                int nc = col + i * dc;
                
                if (!is_valid_grid_position(nr, nc)) break;
                
                if (grid[nr, nc].piece == null) {
                    gaps.add(@"($nr,$nc)");
                } else if (grid[nr, nc].piece.id != piece_type) {
                    break; // Different piece type, stop checking
                }
            }
            
            // Check backward direction  
            for (int i = 1; i <= Game.N_MATCH; i++) {
                int nr = row - i * dr;
                int nc = col - i * dc;
                
                if (!is_valid_grid_position(nr, nc)) break;
                
                if (grid[nr, nc].piece == null) {
                    gaps.add(@"($nr,$nc)");
                } else if (grid[nr, nc].piece.id != piece_type) {
                    break; // Different piece type, stop checking
                }
            }
            
            if (gaps.size > 0) {
                issues.add(@"$(direction_names[d]):$(string.joinv(",", gaps.to_array()))");
            }
        }
        
        return string.joinv("; ", issues.to_array());
    }
    
    private bool is_valid_grid_position(int row, int col) {
        return grid != null && row >= 0 && row < grid.length[0] && col >= 0 && col < grid.length[1];
    }
    
    private string get_neighbor_info(int row, int col) {
        if (grid == null) return "No grid data";
        
        var info = new StringBuilder();
        var directions = new int[,] {
            {-1, -1}, {-1, 0}, {-1, 1},  // Top row
            { 0, -1},          { 0, 1},  // Middle row (excluding center)
            { 1, -1}, { 1, 0}, { 1, 1}   // Bottom row
        };
        
        string[] direction_names = {
            "NW", "N", "NE",
            "W",       "E", 
            "SW", "S", "SE"
        };
        
        int valid_neighbors = 0;
        int occupied_neighbors = 0;
        
        for (int i = 0; i < directions.length[0]; i++) {
            int nr = row + directions[i,0];
            int nc = col + directions[i,1];
            
            if (is_valid_grid_position(nr, nc)) {
                valid_neighbors++;
                if (grid[nr, nc].piece != null) {
                    occupied_neighbors++;
                }
            }
        }
        
        info.append(@"Valid neighbors: $valid_neighbors/8\n");
        info.append(@"Occupied neighbors: $occupied_neighbors/$valid_neighbors\n");
        
        // Show detailed neighbor map for edge/corner positions
        if (valid_neighbors < 8) {
            info.append("Position type: ");
            if (valid_neighbors == 3) info.append("Corner");
            else if (valid_neighbors == 5) info.append("Edge");
            else info.append("Special");
            info.append("\n");
        }
        
        return info.str;
    }
    
    private string analyze_line_directions(int row, int col, int piece_type) {
        if (grid == null) return "No grid";
        
        var directions = new StringBuilder();
        var line_directions = new int[,] {
            {0, 1},   // Horizontal
            {1, 0},   // Vertical  
            {1, 1},   // Diagonal \
            {1, -1}   // Diagonal /
        };
        
        string[] direction_names = {"H", "V", "\\", "/"};
        var found_directions = new Gee.ArrayList<string>();
        
        for (int d = 0; d < line_directions.length[0]; d++) {
            int dr = line_directions[d,0];
            int dc = line_directions[d,1];
            
            // Count in both directions
            int count = 1; // Include current piece
            
            // Count forward
            for (int i = 1; i < Game.N_MATCH; i++) {
                int nr = row + i * dr;
                int nc = col + i * dc;
                if (!is_valid_grid_position(nr, nc) || 
                    grid[nr, nc].piece == null || 
                    grid[nr, nc].piece.id != piece_type) {
                    break;
                }
                count++;
            }
            
            // Count backward
            for (int i = 1; i < Game.N_MATCH; i++) {
                int nr = row - i * dr;
                int nc = col - i * dc;
                if (!is_valid_grid_position(nr, nc) || 
                    grid[nr, nc].piece == null || 
                    grid[nr, nc].piece.id != piece_type) {
                    break;
                }
                count++;
            }
            
            if (count >= 2) { // At least 2 pieces in this direction
                found_directions.add(@"$(direction_names[d])($count)");
            }
        }
        
        if (found_directions.size == 0) {
            return "None";
        }
        
        return string.joinv(", ", found_directions.to_array());
    }
    
    private void log_activity_message(string message) {
        var timestamp = new DateTime.now_local().format("%H:%M:%S");
        var formatted_message = @"[$timestamp] $message\n";
        
        debug_messages.add(formatted_message);
        
        // Keep only last N messages
        var max_messages = get_game_constants().MAX_DEBUG_MESSAGES;
        while (debug_messages.size > max_messages) {
            debug_messages.remove_at(0);
        }
        
        // Update text buffer
        TextIter end_iter;
        debug_log_buffer.get_end_iter(out end_iter);
        debug_log_buffer.insert(ref end_iter, formatted_message, -1);
        
        // Auto-scroll to bottom
        var mark = debug_log_buffer.get_insert();
        debug_log_view.scroll_mark_onscreen(mark);
    }
    
    private void clear_activity_log() {
        debug_messages.clear();
        debug_log_buffer.set_text("", 0);
        log_activity_message("Activity log cleared");
    }
    
    private void export_game_info() {
        var dialog = new FileChooserDialog(
            "Export Game Information",
            null,
            FileChooserAction.SAVE,
            "_Cancel", ResponseType.CANCEL,
            "_Save", ResponseType.ACCEPT
        );
        
        dialog.set_current_name("five-or-more-game-info.txt");
        
        if (dialog.run() == ResponseType.ACCEPT) {
            var filename = dialog.get_filename();
            try {
                var file = File.new_for_path(filename);
                var output_stream = file.create(FileCreateFlags.REPLACE_DESTINATION);
                var data_stream = new DataOutputStream(output_stream);
                
                // Write header
                data_stream.put_string("Five or More - Game Information Export\n");
                data_stream.put_string(@"Exported: $(new DateTime.now_local().format("%Y-%m-%d %H:%M:%S"))\n");
                data_stream.put_string(string.nfill(50, '=') + "\n\n");
                
                // Write current state
                data_stream.put_string("CURRENT STATE:\n");
                data_stream.put_string(@"Game Size: $(game != null ? game.get_board_size().to_string() : "N/A")\n");
                data_stream.put_string(@"Board Dimensions: $(board != null ? @"$(board.n_rows)x$(board.n_cols)" : "N/A")\n");
                data_stream.put_string(@"Selected Position: $(selected_row >= 0 ? @"($selected_row, $selected_col)" : "None")\n\n");
                
                // Write activity log
                data_stream.put_string("ACTIVITY LOG:\n");
                foreach (var message in debug_messages) {
                    data_stream.put_string(message);
                }
                
                data_stream.close();
                log_activity_message(@"Game information exported to: $filename");
            } catch (Error e) {
                log_activity_message(@"Export failed: $(e.message)");
            }
        }
        
        dialog.destroy();
    }
    
    /**
     * Handle board click events for position selection
     */
    internal void on_board_clicked(int row, int col) {
        set_selected_position(row, col);
        
        // Log detailed click information
        log_activity_message(@"Board clicked: Visual($col,$row) → Logical($row,$col)");
        
        // Perform comprehensive boundary validation
        var boundary_status = get_comprehensive_boundary_status(row, col);
        log_activity_message(@"Boundary validation: $boundary_status");
    }
    
    /**
     * Get comprehensive boundary validation status for a position
     */
    private string get_comprehensive_boundary_status(int row, int col) {
        var status = new StringBuilder();
        
        // Basic bounds check
        bool valid_position = is_valid_grid_position(row, col);
        status.append(valid_position ? "VALID" : "INVALID");
        
        if (!valid_position) {
            status.append(" - ");
            if (grid == null) {
                status.append("No grid");
            } else {
                if (row < 0) status.append("Row<0 ");
                if (row >= grid.length[0]) status.append(@"Row>=$(grid.length[0]) ");
                if (col < 0) status.append("Col<0 ");
                if (col >= grid.length[1]) status.append(@"Col>=$(grid.length[1]) ");
            }
        }
        
        // Board consistency check
        if (board != null && grid != null) {
            bool board_grid_consistent = (board.n_rows == grid.length[0] && board.n_cols == grid.length[1]);
            if (!board_grid_consistent) {
                status.append(" - DIMENSION_MISMATCH");
            }
        }
        
        return status.str;
    }
    
    /**
     * Handle game state changes
     */
    internal void on_game_state_changed() {
        if (real_time_enabled) {
            update_all_displays();
        }
        log_activity_message("Game state changed");
    }
    
    /**
     * Handle line detection events
     */
    internal void on_line_detection_performed(int row, int col, bool had_lines) {
        log_activity_message(@"Line detection at ($row, $col): $(had_lines ? "Lines found" : "No lines")");
        
        if (real_time_enabled && selected_row == row && selected_col == col) {
            update_line_detection_display();
            check_phantom_lines();
        }
    }
    
    /**
     * Get boundary validation status for each board position
     */
    internal string get_position_boundary_status(int row, int col) {
        if (!is_valid_grid_position(row, col)) {
            return "INVALID";
        }
        
        var status = new StringBuilder();
        
        // Basic validation
        status.append("VALID");
        
        // Add position characteristics
        if (board != null) {
            bool is_corner = (row == 0 || row == board.n_rows - 1) && (col == 0 || col == board.n_cols - 1);
            bool is_edge = !is_corner && (row == 0 || row == board.n_rows - 1 || col == 0 || col == board.n_cols - 1);
            
            if (is_corner) status.append("-CORNER");
            else if (is_edge) status.append("-EDGE");
            else status.append("-CENTER");
        }
        
        // Add piece information
        if (grid != null && grid[row, col].piece != null) {
            status.append(@"-PIECE$(grid[row, col].piece.id)");
        } else {
            status.append("-EMPTY");
        }
        
        return status.str;
    }
    
    /**
     * Validate coordinate mapping between visual and logical systems
     */
    internal bool validate_coordinate_mapping(int visual_x, int visual_y, int logical_row, int logical_col) {
        // In Five or More, visual coordinates (x,y) map to logical coordinates (row,col) as:
        // visual_x → logical_col, visual_y → logical_row
        bool mapping_correct = (visual_x == logical_col && visual_y == logical_row);
        
        if (!mapping_correct) {
            log_activity_message(@"⚠️ Coordinate mapping error: Visual($visual_x,$visual_y) ≠ Logical($logical_row,$logical_col)");
        }
        
        return mapping_correct;
    }
    
    /**
     * Inspect any position on the board (for programmatic debugging)
     */
    internal string inspect_position(int row, int col) {
        var inspection = new StringBuilder();
        inspection.append(@"🔍 POSITION INSPECTION ($row, $col)\n");
        
        // Boundary validation
        bool valid = is_valid_grid_position(row, col);
        inspection.append(@"Valid: $(valid ? "✅" : "❌")\n");
        
        if (!valid) {
            inspection.append("Cannot inspect invalid position\n");
            return inspection.str;
        }
        
        // Piece information
        var cell = grid[row, col];
        if (cell.piece != null) {
            inspection.append(@"Piece: Type $(cell.piece.id)\n");
            
            // Line detection analysis
            var traditional_cells = cell.get_all_directions(grid);
            inspection.append(@"Traditional lines: $(traditional_cells.size) pieces\n");
            
            var line_detector = new LineDetector(grid);
            var composite_lines = line_detector.detect_composite_lines(row, col);
            inspection.append(@"Composite patterns: $(composite_lines.size)\n");
            
        } else {
            inspection.append("Piece: Empty\n");
        }
        
        // Boundary characteristics
        if (board != null) {
            bool is_corner = (row == 0 || row == board.n_rows - 1) && (col == 0 || col == board.n_cols - 1);
            bool is_edge = !is_corner && (row == 0 || row == board.n_rows - 1 || col == 0 || col == board.n_cols - 1);
            
            if (is_corner) inspection.append("Type: Corner position\n");
            else if (is_edge) inspection.append("Type: Edge position\n");
            else inspection.append("Type: Center position\n");
        }
        
        return inspection.str;
    }
    
    /**
     * Get a summary of all boundary validation issues on the current board
     */
    internal string get_board_boundary_summary() {
        if (board == null || grid == null) {
            return "No board loaded";
        }
        
        var summary = new StringBuilder();
        summary.append(@"📊 BOARD BOUNDARY SUMMARY\n");
        summary.append(@"Board: $(board.n_rows)×$(board.n_cols)\n");
        summary.append(@"Grid: $(grid.length[0])×$(grid.length[1])\n");
        
        // Check dimension consistency
        bool dimensions_consistent = (board.n_rows == grid.length[0] && board.n_cols == grid.length[1]);
        summary.append(@"Dimensions: $(dimensions_consistent ? "✅ Consistent" : "❌ Mismatch")\n");
        
        // Count position types
        int corners = 0, edges = 0, centers = 0, occupied = 0;
        
        for (int row = 0; row < board.n_rows; row++) {
            for (int col = 0; col < board.n_cols; col++) {
                bool is_corner = (row == 0 || row == board.n_rows - 1) && (col == 0 || col == board.n_cols - 1);
                bool is_edge = !is_corner && (row == 0 || row == board.n_rows - 1 || col == 0 || col == board.n_cols - 1);
                
                if (is_corner) corners++;
                else if (is_edge) edges++;
                else centers++;
                
                if (grid[row, col].piece != null) occupied++;
            }
        }
        
        summary.append(@"Corners: $corners, Edges: $edges, Centers: $centers\n");
        summary.append(@"Occupied: $occupied/$(board.n_rows * board.n_cols)\n");
        
        return summary.str;
    }
}