/*
 * Five or More - Window Testing Framework
 * Test Fixtures and Data
 * 
 * This file provides reusable test data and configurations.
 */

using Gtk;

namespace FiveOrMoreTest {

    /**
     * Window state configurations for testing
     */
    public struct WindowStateFixture {
        public int width;
        public int height;
        public bool maximized;
        public bool tiled;
        public string description;
        
        public WindowStateFixture(int w, int h, bool max, bool tile, string desc) {
            width = w;
            height = h;
            maximized = max;
            tiled = tile;
            description = desc;
        }
    }
    
    /**
     * Theme configurations for testing
     */
    public struct ThemeFixture {
        public string theme_name;
        public string background_color;
        public string description;
        
        public ThemeFixture(string theme, string bg_color, string desc) {
            theme_name = theme;
            background_color = bg_color;
            description = desc;
        }
    }
    
    /**
     * Game state configurations for testing
     */
    public struct GameStateFixture {
        public int board_size;
        public int score;
        public string status_message;
        public string description;
        
        public GameStateFixture(int size, int game_score, string status, string desc) {
            board_size = size;
            score = game_score;
            status_message = status;
            description = desc;
        }
    }
    
    /**
     * Collection of predefined test fixtures
     */
    public class TestFixtures : GLib.Object {
        
        // Default window dimensions from requirements (now configurable)
        public static int DEFAULT_WIDTH { get { return get_game_constants().DEFAULT_WINDOW_WIDTH; } }
        public static int DEFAULT_HEIGHT { get { return get_game_constants().DEFAULT_WINDOW_HEIGHT; } }
        
        // Window state fixtures
        public static WindowStateFixture[] window_states = {
            WindowStateFixture(320, 400, false, false, "Default window size"),
            WindowStateFixture(640, 480, false, false, "Medium window size"),
            WindowStateFixture(800, 600, false, false, "Large window size"),
            WindowStateFixture(1024, 768, true, false, "Maximized window"),
            WindowStateFixture(500, 300, false, true, "Tiled window"),
        };
        
        // Theme fixtures
        public static ThemeFixture[] themes = {
            ThemeFixture("balls.svg", "#000000", "Default balls theme with black background"),
            ThemeFixture("shapes.svg", "#FFFFFF", "Shapes theme with white background"),
            ThemeFixture("tango.svg", "#808080", "Tango theme with gray background"),
        };
        
        // Game state fixtures
        public static GameStateFixture[] game_states = {
            GameStateFixture(1, 0, "Match five objects of the same type in a row to score!", "New small game"),
            GameStateFixture(2, 150, "Score: 150", "Medium game in progress"),
            GameStateFixture(3, 500, "Score: 500", "Large game with high score"),
            GameStateFixture(2, 0, "Game Over!", "Game over state"),
            GameStateFixture(1, 0, "You can't move there!", "Invalid move state"),
        };
        
        /**
         * Get default window state fixture
         */
        public static WindowStateFixture get_default_window_state() {
            return window_states[0];
        }
        
        /**
         * Get window state fixture by description
         */
        public static WindowStateFixture? get_window_state_by_description(string description) {
            foreach (var state in window_states) {
                if (state.description == description) {
                    return state;
                }
            }
            return null;
        }
        
        /**
         * Get theme fixture by name
         */
        public static ThemeFixture? get_theme_by_name(string theme_name) {
            foreach (var theme in themes) {
                if (theme.theme_name == theme_name) {
                    return theme;
                }
            }
            return null;
        }
        
        /**
         * Get game state fixture by description
         */
        public static GameStateFixture? get_game_state_by_description(string description) {
            foreach (var state in game_states) {
                if (state.description == description) {
                    return state;
                }
            }
            return null;
        }
        
        /**
         * Create a mock settings instance with specific window state
         */
        public static MockSettings create_mock_settings_with_window_state(WindowStateFixture state) {
            var mock_settings = new MockSettings();
            mock_settings.setup_window_state(state.width, state.height, state.maximized);
            return mock_settings;
        }
        
        /**
         * Create a mock settings instance with specific theme
         */
        public static MockSettings create_mock_settings_with_theme(ThemeFixture theme) {
            var mock_settings = new MockSettings();
            mock_settings.setup_theme(theme.theme_name);
            mock_settings.setup_background_color(theme.background_color);
            return mock_settings;
        }
        
        /**
         * Validate window dimensions against fixture
         */
        public static bool validate_window_dimensions(ApplicationWindow window, WindowStateFixture expected) {
            int actual_width, actual_height;
            window.get_size(out actual_width, out actual_height);
            
            Test.message("Validating window dimensions: expected %dx%d, actual %dx%d", 
                        expected.width, expected.height, actual_width, actual_height);
            
            return (actual_width == expected.width && actual_height == expected.height);
        }
        
        /**
         * Validate window maximized state against fixture
         */
        public static bool validate_window_maximized_state(ApplicationWindow window, WindowStateFixture expected) {
            bool is_maximized = window.is_maximized;
            
            Test.message("Validating window maximized state: expected %s, actual %s", 
                        expected.maximized.to_string(), is_maximized.to_string());
            
            return (is_maximized == expected.maximized);
        }
    }
    
    /**
     * Test data generator for creating various test scenarios
     */
    public class TestDataGenerator : GLib.Object {
        
        /**
         * Generate random window dimensions within reasonable bounds
         */
        public static WindowStateFixture generate_random_window_state() {
            var random = new Rand();
            int width = random.int_range(300, 1200);
            int height = random.int_range(200, 800);
            bool maximized = random.boolean();
            
            return WindowStateFixture(width, height, maximized, false, 
                                    "Random generated: %dx%d".printf(width, height));
        }
        
        /**
         * Generate invalid window dimensions for error testing
         */
        public static WindowStateFixture[] generate_invalid_window_states() {
            return {
                WindowStateFixture(-1, 400, false, false, "Negative width"),
                WindowStateFixture(320, -1, false, false, "Negative height"),
                WindowStateFixture(0, 400, false, false, "Zero width"),
                WindowStateFixture(320, 0, false, false, "Zero height"),
                WindowStateFixture(50000, 400, false, false, "Extremely large width"),
                WindowStateFixture(320, 50000, false, false, "Extremely large height"),
            };
        }
        
        /**
         * Generate test color values
         */
        public static string[] generate_test_colors() {
            return {
                "#000000", // Black
                "#FFFFFF", // White
                "#FF0000", // Red
                "#00FF00", // Green
                "#0000FF", // Blue
                "#808080", // Gray
                "#FFFF00", // Yellow
                "#FF00FF", // Magenta
                "#00FFFF", // Cyan
            };
        }
    }
}