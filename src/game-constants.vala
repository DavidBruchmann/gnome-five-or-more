/*
 * Five or More - Game Constants Configuration
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

/**
 * Centralized game constants that can be configured
 * This class loads default values and allows user overrides
 */
internal class GameConstants : Object {

    // Singleton instance
    private static GameConstants? _instance = null;
    internal static GameConstants instance {
        get {
            if (_instance == null) {
                _instance = new GameConstants();
            }
            return _instance;
        }
    }

    // Core Game Rules
    internal int N_MATCH { get; private set; default = 5; }
    internal int N_TYPES { get; private set; default = 7; }
    internal int N_ANIMATIONS { get; private set; default = 4; }
    internal bool ENABLE_COMPOSITE_LINES { get; set; default = false; }

    // Board Sizes (Small, Medium, Large)
    internal GameDifficulty[] game_difficulty { get; private set; }

    // Difficulty Levels
    internal DifficultyLevel[] difficulty_levels { get; private set; }

    // UI Constants
    internal int MINIMUM_BOARD_SIZE { get; private set; default = 256; }
    internal int DEBUG_PANEL_WIDTH { get; private set; default = 350; }
    internal int DEBUG_LOG_HEIGHT { get; private set; default = 150; }
    internal int MAX_DEBUG_MESSAGES { get; private set; default = 100; }

    // Scoring Constants
    internal int SCORE_BASE_MULTIPLIER { get; private set; default = 45; }
    internal double SCORE_LOG_FACTOR { get; private set; default = 0.25; }

    // Animation Constants
    internal int ANIMATION_DURATION_MS { get; private set; default = 1500; }
    internal int ANIMATION_FRAME_MS { get; private set; default = 50; }
    internal int ANIMATION_STEP_MS { get; private set; default = 20; }

    // Composite Line Effects
    internal int COMPOSITE_BASE_BONUS { get; private set; default = 25; }
    internal int COMPOSITE_COMPLEXITY_BONUS { get; private set; default = 15; }

    // Accessibility Constants
    internal double WCAG_AA_RATIO { get; private set; default = 4.5; }
    internal double WCAG_AAA_RATIO { get; private set; default = 7.0; }
    internal double COLORBLIND_THRESHOLD_BASE { get; private set; default = 50.0; }
    internal double COLORBLIND_THRESHOLD_RG { get; private set; default = 75.0; }

    // Theme and Rendering
    internal double DEFAULT_PIECE_RADIUS { get; private set; default = 37.5; }
    internal int THEME_SPRITE_BASE_SIZE { get; private set; default = 100; }
    internal int SVG_TEMPLATE_WIDTH { get; private set; default = 400; }
    internal int SVG_TEMPLATE_HEIGHT { get; private set; default = 700; }
    
    // Next Pieces Preview
    internal int NEXT_PIECES_SIZE { get; private set; default = 24; }
    internal bool NEXT_PIECES_SHOW_TOOLTIPS { get; private set; default = true; }

    // Window and UI Defaults
    internal int DEFAULT_WINDOW_WIDTH { get; private set; default = 320; }
    internal int DEFAULT_WINDOW_HEIGHT { get; private set; default = 400; }
    internal int MAX_WINDOW_WIDTH { get; private set; default = 4096; }
    internal int MAX_WINDOW_HEIGHT { get; private set; default = 4096; }

    // Development and Debug
    internal uint MAX_DEBUG_LOG_MESSAGES { get; private set; default = 1000; }
    internal uint DEFAULT_UI_UPDATE_TIMEOUT { get; private set; default = 100; }
    internal uint DEFAULT_TEST_TIMEOUT { get; private set; default = 30; }

    // File paths for user configuration
    private const string USER_CONFIG_DIR = ".config/five-or-more";
    private const string USER_CONFIG_FILE = "game-constants.conf";
    private const string SYSTEM_CONFIG_FILE = "/etc/five-or-more/game-constants.conf";

    construct {
        initialize_defaults();
        load_user_configuration();
    }

    private void initialize_defaults() {
        // Initialize default game difficulty settings
        game_difficulty = {
            { -1, -1, -1, -1 },  // Invalid/placeholder
            {  7,  7,  5,  3 },  // Small
            {  9,  9,  7,  3 },  // Medium
            { 20, 15,  7,  7 }   // Large
        };

        // Initialize default difficulty levels
        // Array indices: [0]=invalid, [1]=small, [2]=medium, [3]=large
        difficulty_levels = {
            { "easy",   "Easy",   {0, 2, 3, 4} },  // Easy: 2/3/4 pieces per round
            { "normal", "Normal", {0, 2, 3, 4} },  // Normal: 2/3/4 pieces per round (default)
            { "hard",   "Hard",   {0, 4, 7, 10} }  // Hard: 4/7/10 pieces per round
        };
    }

    private void load_user_configuration() {
        // Try to load user configuration first
        string user_config_path = Path.build_filename(
            Environment.get_home_dir(),
            USER_CONFIG_DIR,
            USER_CONFIG_FILE
        );

        if (FileUtils.test(user_config_path, FileTest.EXISTS)) {
            load_configuration_file(user_config_path);
            return;
        }

        // Fall back to system configuration
        if (FileUtils.test(SYSTEM_CONFIG_FILE, FileTest.EXISTS)) {
            load_configuration_file(SYSTEM_CONFIG_FILE);
        }
    }

    private void load_configuration_file(string config_path) {
        try {
            var key_file = new KeyFile();
            key_file.load_from_file(config_path, KeyFileFlags.NONE);

            // Load core game rules
            if (key_file.has_group("GameRules")) {
                try {
                    if (key_file.has_key("GameRules", "N_MATCH"))
                        N_MATCH = key_file.get_integer("GameRules", "N_MATCH");
                    if (key_file.has_key("GameRules", "N_TYPES"))
                        N_TYPES = key_file.get_integer("GameRules", "N_TYPES");
                    if (key_file.has_key("GameRules", "N_ANIMATIONS"))
                        N_ANIMATIONS = key_file.get_integer("GameRules", "N_ANIMATIONS");
                    if (key_file.has_key("GameRules", "ENABLE_COMPOSITE_LINES"))
                        ENABLE_COMPOSITE_LINES = key_file.get_boolean("GameRules", "ENABLE_COMPOSITE_LINES");
                } catch (Error e) {
                    warning("Failed to load GameRules: %s", e.message);
                }
            }

            // Load board configurations
            load_board_configurations(key_file);

            // Load difficulty configurations
            load_difficulty_configurations(key_file, 0);

            // Load UI constants
            if (key_file.has_group("UI")) {
                try {
                    if (key_file.has_key("UI", "MINIMUM_BOARD_SIZE"))
                        MINIMUM_BOARD_SIZE = key_file.get_integer("UI", "MINIMUM_BOARD_SIZE");
                    if (key_file.has_key("UI", "DEBUG_PANEL_WIDTH"))
                        DEBUG_PANEL_WIDTH = key_file.get_integer("UI", "DEBUG_PANEL_WIDTH");
                    if (key_file.has_key("UI", "DEBUG_LOG_HEIGHT"))
                        DEBUG_LOG_HEIGHT = key_file.get_integer("UI", "DEBUG_LOG_HEIGHT");
                    if (key_file.has_key("UI", "MAX_DEBUG_MESSAGES"))
                        MAX_DEBUG_MESSAGES = key_file.get_integer("UI", "MAX_DEBUG_MESSAGES");
                } catch (Error e) {
                    warning("Failed to load UI constants: %s", e.message);
                }
            }

            // Load scoring constants
            if (key_file.has_group("Scoring")) {
                try {
                    if (key_file.has_key("Scoring", "SCORE_BASE_MULTIPLIER"))
                        SCORE_BASE_MULTIPLIER = key_file.get_integer("Scoring", "SCORE_BASE_MULTIPLIER");
                    if (key_file.has_key("Scoring", "SCORE_LOG_FACTOR"))
                        SCORE_LOG_FACTOR = key_file.get_double("Scoring", "SCORE_LOG_FACTOR");
                } catch (Error e) {
                    warning("Failed to load Scoring constants: %s", e.message);
                }
            }

            // Load animation constants
            if (key_file.has_group("Animation")) {
                try {
                    if (key_file.has_key("Animation", "ANIMATION_DURATION_MS"))
                        ANIMATION_DURATION_MS = key_file.get_integer("Animation", "ANIMATION_DURATION_MS");
                    if (key_file.has_key("Animation", "ANIMATION_FRAME_MS"))
                        ANIMATION_FRAME_MS = key_file.get_integer("Animation", "ANIMATION_FRAME_MS");
                    if (key_file.has_key("Animation", "ANIMATION_STEP_MS"))
                        ANIMATION_STEP_MS = key_file.get_integer("Animation", "ANIMATION_STEP_MS");
                } catch (Error e) {
                    warning("Failed to load Animation constants: %s", e.message);
                }
            }

            // Load accessibility constants
            if (key_file.has_group("Accessibility")) {
                try {
                    if (key_file.has_key("Accessibility", "WCAG_AA_RATIO"))
                        WCAG_AA_RATIO = key_file.get_double("Accessibility", "WCAG_AA_RATIO");
                    if (key_file.has_key("Accessibility", "WCAG_AAA_RATIO"))
                        WCAG_AAA_RATIO = key_file.get_double("Accessibility", "WCAG_AAA_RATIO");
                    if (key_file.has_key("Accessibility", "COLORBLIND_THRESHOLD_BASE"))
                        COLORBLIND_THRESHOLD_BASE = key_file.get_double("Accessibility", "COLORBLIND_THRESHOLD_BASE");
                    if (key_file.has_key("Accessibility", "COLORBLIND_THRESHOLD_RG"))
                        COLORBLIND_THRESHOLD_RG = key_file.get_double("Accessibility", "COLORBLIND_THRESHOLD_RG");
                } catch (Error e) {
                    warning("Failed to load Accessibility constants: %s", e.message);
                }
            }

            // Load theme constants
            if (key_file.has_group("Theme")) {
                try {
                    if (key_file.has_key("Theme", "DEFAULT_PIECE_RADIUS"))
                        DEFAULT_PIECE_RADIUS = key_file.get_double("Theme", "DEFAULT_PIECE_RADIUS");
                    if (key_file.has_key("Theme", "THEME_SPRITE_BASE_SIZE"))
                        THEME_SPRITE_BASE_SIZE = key_file.get_integer("Theme", "THEME_SPRITE_BASE_SIZE");
                    if (key_file.has_key("Theme", "SVG_TEMPLATE_WIDTH"))
                        SVG_TEMPLATE_WIDTH = key_file.get_integer("Theme", "SVG_TEMPLATE_WIDTH");
                    if (key_file.has_key("Theme", "SVG_TEMPLATE_HEIGHT"))
                        SVG_TEMPLATE_HEIGHT = key_file.get_integer("Theme", "SVG_TEMPLATE_HEIGHT");
                    if (key_file.has_key("Theme", "NEXT_PIECES_SIZE"))
                        NEXT_PIECES_SIZE = key_file.get_integer("Theme", "NEXT_PIECES_SIZE");
                    if (key_file.has_key("Theme", "NEXT_PIECES_SHOW_TOOLTIPS"))
                        NEXT_PIECES_SHOW_TOOLTIPS = key_file.get_boolean("Theme", "NEXT_PIECES_SHOW_TOOLTIPS");
                } catch (Error e) {
                    warning("Failed to load Theme constants: %s", e.message);
                }
            }

            // Load window defaults
            if (key_file.has_group("Window")) {
                try {
                    if (key_file.has_key("Window", "DEFAULT_WINDOW_WIDTH"))
                        DEFAULT_WINDOW_WIDTH = key_file.get_integer("Window", "DEFAULT_WINDOW_WIDTH");
                    if (key_file.has_key("Window", "DEFAULT_WINDOW_HEIGHT"))
                        DEFAULT_WINDOW_HEIGHT = key_file.get_integer("Window", "DEFAULT_WINDOW_HEIGHT");
                    if (key_file.has_key("Window", "MAX_WINDOW_WIDTH"))
                        MAX_WINDOW_WIDTH = key_file.get_integer("Window", "MAX_WINDOW_WIDTH");
                    if (key_file.has_key("Window", "MAX_WINDOW_HEIGHT"))
                        MAX_WINDOW_HEIGHT = key_file.get_integer("Window", "MAX_WINDOW_HEIGHT");
                } catch (Error e) {
                    warning("Failed to load Window constants: %s", e.message);
                }
            }

        } catch (Error e) {
            warning("Failed to load configuration from %s: %s", config_path, e.message);
        }
    }

    private void load_board_configurations(KeyFile key_file) {
        if (!key_file.has_group("BoardSizes")) return;

        try {
            // Load small board
            if (key_file.has_key("BoardSizes", "small")) {
                var small_values = key_file.get_integer_list("BoardSizes", "small");
                if (small_values.length >= 4) {
                    game_difficulty[1] = {
                        (int)small_values[0], (int)small_values[1],
                        (int)small_values[2], (int)small_values[3]
                    };
                }
            }

            // Load medium board
            if (key_file.has_key("BoardSizes", "medium")) {
                var medium_values = key_file.get_integer_list("BoardSizes", "medium");
                if (medium_values.length >= 4) {
                    game_difficulty[2] = {
                        (int)medium_values[0], (int)medium_values[1],
                        (int)medium_values[2], (int)medium_values[3]
                    };
                }
            }

            // Load large board
            if (key_file.has_key("BoardSizes", "large")) {
                var large_values = key_file.get_integer_list("BoardSizes", "large");
                if (large_values.length >= 4) {
                    game_difficulty[3] = {
                        (int)large_values[0], (int)large_values[1],
                        (int)large_values[2], (int)large_values[3]
                    };
                }
            }
        } catch (Error e) {
            warning("Failed to load board configurations: %s", e.message);
        }
    }

    private void load_difficulty_configurations(KeyFile key_file, int size) {
        if (!key_file.has_group("Difficulty")) return;

        try {
            // Load easy difficulty
            if (key_file.has_key("Difficulty", "easy_pieces")) {
                var easy_values = parse_difficulty_values(key_file.get_string("Difficulty", "easy_pieces"));
                if (easy_values.length >= 3) {
                    difficulty_levels[0].pieces_per_round = {0, easy_values[0], easy_values[1], easy_values[2]};
                }
            }

            // Load normal difficulty
            if (key_file.has_key("Difficulty", "normal_pieces")) {
                var normal_values = parse_difficulty_values(key_file.get_string("Difficulty", "normal_pieces"));
                if (normal_values.length >= 3) {
                    difficulty_levels[1].pieces_per_round = {0, normal_values[0], normal_values[1], normal_values[2]};
                }
            }

            // Load hard difficulty
            if (key_file.has_key("Difficulty", "hard_pieces")) {
                var hard_values = parse_difficulty_values(key_file.get_string("Difficulty", "hard_pieces"));
                if (hard_values.length >= 3) {
                    difficulty_levels[2].pieces_per_round = {0, hard_values[0], hard_values[1], hard_values[2]};
                }
            }
        } catch (Error e) {
            warning("Failed to load difficulty configurations: %s", e.message);
        }
    }

    private int[] parse_difficulty_values(string values_string) {
        var parts = values_string.split(";");
        var result = new int[parts.length];
        
        for (int i = 0; i < parts.length; i++) {
            result[i] = int.parse(parts[i].strip());
        }
        
        return result;
    }

    /**
     * Create a sample configuration file for users
     */
    internal void create_sample_config() {
        string user_config_dir = Path.build_filename(
            Environment.get_home_dir(),
            USER_CONFIG_DIR
        );

        string user_config_path = Path.build_filename(
            user_config_dir,
            USER_CONFIG_FILE
        );

        try {
            // Create directory if it doesn't exist
            DirUtils.create_with_parents(user_config_dir, 0755);

            var key_file = new KeyFile();

            // Add comments and default values
            key_file.set_comment(null, null,
                "Five or More Game Constants Configuration\n" +
                "Modify these values to customize game behavior\n" +
                "Remove any section or key to use default values");

            // Game Rules
            key_file.set_integer("GameRules", "N_MATCH", N_MATCH);
            key_file.set_integer("GameRules", "N_TYPES", N_TYPES);
            key_file.set_integer("GameRules", "N_ANIMATIONS", N_ANIMATIONS);
            key_file.set_boolean("GameRules", "ENABLE_COMPOSITE_LINES", ENABLE_COMPOSITE_LINES);
            key_file.set_comment("GameRules", "N_MATCH", "Number of pieces needed to form a line");
            key_file.set_comment("GameRules", "N_TYPES", "Number of different piece types");
            key_file.set_comment("GameRules", "N_ANIMATIONS", "Number of animation frames");
            key_file.set_comment("GameRules", "ENABLE_COMPOSITE_LINES", "Enable combo play (gap-separated patterns like 2+3, 3+2)");

            // Board Sizes (cols, rows, types, next_pieces)
            key_file.set_integer_list("BoardSizes", "small", {7, 7, 5, 3});
            key_file.set_integer_list("BoardSizes", "medium", {9, 9, 7, 3});
            key_file.set_integer_list("BoardSizes", "large", {20, 15, 7, 7});
            key_file.set_comment("BoardSizes", null, "Board configurations: cols, rows, piece_types, next_pieces");

            // Difficulty Levels
            key_file.set_string("Difficulty", "easy_pieces", "2;3;4");
            key_file.set_string("Difficulty", "normal_pieces", "2;3;4");
            key_file.set_string("Difficulty", "hard_pieces", "4;7;10");
            key_file.set_comment("Difficulty", null, "Number of pieces added per round for each difficulty\nValues are for small;medium;large board sizes respectively");
            key_file.set_comment("Difficulty", "easy_pieces", "Easy difficulty pieces per round (small;medium;large)");
            key_file.set_comment("Difficulty", "normal_pieces", "Normal difficulty pieces per round (small;medium;large)");
            key_file.set_comment("Difficulty", "hard_pieces", "Hard difficulty pieces per round (small;medium;large)");

            // UI Constants
            key_file.set_integer("UI", "MINIMUM_BOARD_SIZE", MINIMUM_BOARD_SIZE);
            key_file.set_integer("UI", "DEBUG_PANEL_WIDTH", DEBUG_PANEL_WIDTH);
            key_file.set_integer("UI", "DEBUG_LOG_HEIGHT", DEBUG_LOG_HEIGHT);
            key_file.set_integer("UI", "MAX_DEBUG_MESSAGES", MAX_DEBUG_MESSAGES);

            // Scoring
            key_file.set_integer("Scoring", "SCORE_BASE_MULTIPLIER", SCORE_BASE_MULTIPLIER);
            key_file.set_double("Scoring", "SCORE_LOG_FACTOR", SCORE_LOG_FACTOR);

            // Animation
            key_file.set_integer("Animation", "ANIMATION_DURATION_MS", ANIMATION_DURATION_MS);
            key_file.set_integer("Animation", "ANIMATION_FRAME_MS", ANIMATION_FRAME_MS);
            key_file.set_integer("Animation", "ANIMATION_STEP_MS", ANIMATION_STEP_MS);

            // Accessibility
            key_file.set_double("Accessibility", "WCAG_AA_RATIO", WCAG_AA_RATIO);
            key_file.set_double("Accessibility", "WCAG_AAA_RATIO", WCAG_AAA_RATIO);
            key_file.set_double("Accessibility", "COLORBLIND_THRESHOLD_BASE", COLORBLIND_THRESHOLD_BASE);
            key_file.set_double("Accessibility", "COLORBLIND_THRESHOLD_RG", COLORBLIND_THRESHOLD_RG);

            // Theme
            key_file.set_double("Theme", "DEFAULT_PIECE_RADIUS", DEFAULT_PIECE_RADIUS);
            key_file.set_integer("Theme", "THEME_SPRITE_BASE_SIZE", THEME_SPRITE_BASE_SIZE);
            key_file.set_integer("Theme", "SVG_TEMPLATE_WIDTH", SVG_TEMPLATE_WIDTH);
            key_file.set_integer("Theme", "SVG_TEMPLATE_HEIGHT", SVG_TEMPLATE_HEIGHT);
            key_file.set_integer("Theme", "NEXT_PIECES_SIZE", NEXT_PIECES_SIZE);
            key_file.set_boolean("Theme", "NEXT_PIECES_SHOW_TOOLTIPS", NEXT_PIECES_SHOW_TOOLTIPS);
            key_file.set_comment("Theme", "NEXT_PIECES_SIZE", "Size of next pieces preview in header bar (pixels)");
            key_file.set_comment("Theme", "NEXT_PIECES_SHOW_TOOLTIPS", "Show color names as tooltips on next pieces");

            // Window
            key_file.set_integer("Window", "DEFAULT_WINDOW_WIDTH", DEFAULT_WINDOW_WIDTH);
            key_file.set_integer("Window", "DEFAULT_WINDOW_HEIGHT", DEFAULT_WINDOW_HEIGHT);
            key_file.set_integer("Window", "MAX_WINDOW_WIDTH", MAX_WINDOW_WIDTH);
            key_file.set_integer("Window", "MAX_WINDOW_HEIGHT", MAX_WINDOW_HEIGHT);

            // Save the file
            key_file.save_to_file(user_config_path);

            message("Sample configuration created at: %s", user_config_path);

        } catch (Error e) {
            warning("Failed to create sample configuration: %s", e.message);
        }
    }

    /**
     * Validate configuration values
     */
    internal bool validate_configuration() {
        bool valid = true;

        if (N_MATCH < 3 || N_MATCH > 10) {
            warning("Invalid N_MATCH value: %d (should be 3-10)", N_MATCH);
            valid = false;
        }

        if (N_TYPES < 3 || N_TYPES > 12) {
            warning("Invalid N_TYPES value: %d (should be 3-12)", N_TYPES);
            valid = false;
        }

        if (N_ANIMATIONS < 1 || N_ANIMATIONS > 8) {
            warning("Invalid N_ANIMATIONS value: %d (should be 1-8)", N_ANIMATIONS);
            valid = false;
        }

        // Validate board sizes
        for (int i = 1; i < game_difficulty.length; i++) {
            var diff = game_difficulty[i];
            if (diff.n_cols < 5 || diff.n_cols > 50 || diff.n_rows < 5 || diff.n_rows > 50) {
                warning("Invalid board size for difficulty %d: %dx%d", i, diff.n_cols, diff.n_rows);
                valid = false;
            }
        }

        return valid;
    }
}

/**
 * Convenience function to get game constants instance
 */
internal GameConstants get_game_constants() {
    return GameConstants.instance;
}
