/*
 * Five or More - Window Testing Framework
 * Base Test Class
 * 
 * This file provides the base testing infrastructure for window testing.
 */

using Gtk;

namespace FiveOrMoreTest {

    /**
     * Base class for all window tests providing common functionality
     */
    public abstract class TestBase : GLib.Object {
        
        protected static bool gtk_initialized = false;
        protected static Gtk.Application? shared_app = null;
        protected ApplicationWindow? test_window = null;
        protected Gtk.Application? test_app = null;
        
        /**
         * Initialize GTK for testing if not already done
         */
        protected static void ensure_gtk_init() {
            if (!gtk_initialized) {
                // Initialize GTK for testing - use empty args
                string[] empty_args = {};
                unowned string[] args = empty_args;
                Gtk.init(ref args);
                gtk_initialized = true;
            }
        }
        
        /**
         * Set up test environment before each test
         */
        public virtual void setup() {
            ensure_gtk_init();
            
            // Use shared application or create new one
            if (shared_app == null) {
                shared_app = new Gtk.Application("org.gnome.five_or_more.test", ApplicationFlags.FLAGS_NONE);
                
                // Connect to activate signal
                shared_app.activate.connect(() => {
                    // Do nothing - windows will be created manually
                });
                
                try {
                    shared_app.register();
                } catch (Error e) {
                    Test.message("Failed to register test application: %s", e.message);
                }
            }
            
            test_app = shared_app;
            
            // Create test window
            test_window = new ApplicationWindow(test_app);
            test_window.set_default_size(320, 400);
            test_window.set_title("Five or More Test");
            test_app.add_window(test_window);
        }
        
        /**
         * Clean up test environment after each test
         */
        public virtual void teardown() {
            if (test_window != null) {
                test_window.destroy();
                test_window = null;
            }
            
            if (test_app != null) {
                test_app.quit();
                test_app = null;
            }
        }
        
        /**
         * Wait for GTK main loop to process pending events
         */
        protected void process_pending_events() {
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
        }
        
        /**
         * Wait for a specific timeout to allow UI updates
         */
        protected void wait_for_ui_update(uint timeout_ms = 0) {
            if (timeout_ms == 0) timeout_ms = get_game_constants().DEFAULT_UI_UPDATE_TIMEOUT;
            var main_loop = new MainLoop();
            Timeout.add(timeout_ms, () => {
                main_loop.quit();
                return false;
            });
            main_loop.run();
            process_pending_events();
        }
        
        /**
         * Assert that a widget is visible and realized
         */
        protected void assert_widget_visible(Widget widget, string widget_name) {
            Test.message("Checking visibility of %s", widget_name);
            assert_true(widget.get_visible());
            assert_true(widget.get_realized());
        }
        
        /**
         * Assert window dimensions match expected values
         */
        protected void assert_window_size(int expected_width, int expected_height) {
            int actual_width, actual_height;
            test_window.get_size(out actual_width, out actual_height);
            
            Test.message("Expected window size: %dx%d, Actual: %dx%d", 
                        expected_width, expected_height, actual_width, actual_height);
            
            assert_cmpint(actual_width, CompareOperator.EQ, expected_width);
            assert_cmpint(actual_height, CompareOperator.EQ, expected_height);
        }
        
        /**
         * Get HeaderBar from test window
         */
        protected HeaderBar? get_headerbar() {
            return test_window.get_titlebar() as HeaderBar;
        }
        
        /**
         * Trigger a window resize and wait for processing
         */
        protected void resize_window(int width, int height) {
            test_window.resize(width, height);
            wait_for_ui_update(200);
        }
        
        /**
         * Maximize window and wait for processing
         */
        protected void maximize_window() {
            test_window.maximize();
            wait_for_ui_update(200);
        }
        
        /**
         * Unmaximize window and wait for processing
         */
        protected void unmaximize_window() {
            test_window.unmaximize();
            wait_for_ui_update(200);
        }
    }
    
    /**
     * Test suite runner for organizing and executing tests
     */
    public class TestSuiteRunner : GLib.Object {
        
        private string suite_name;
        private List<TestCase> test_cases;
        
        public TestSuiteRunner(string name) {
            suite_name = name;
            test_cases = new List<TestCase>();
        }
        
        public void add_test_case(TestCase test_case) {
            test_cases.append(test_case);
        }
        
        public void run_all_tests() {
            Test.message("Running test suite: %s", suite_name);
            
            foreach (var test_case in test_cases) {
                Test.message("Executing test: %s", test_case.name);
                
                try {
                    test_case.setup();
                    test_case.execute();
                    Test.message("✓ Test passed: %s", test_case.name);
                } catch (Error e) {
                    Test.message("✗ Test failed: %s - %s", test_case.name, e.message);
                    Test.fail();
                } finally {
                    test_case.teardown();
                }
            }
            
            Test.message("Completed test suite: %s", suite_name);
        }
    }
    
    /**
     * Individual test case wrapper
     */
    public class TestCase : GLib.Object {
        
        public string name { get; private set; }
        private TestBase test_instance;
        
        public delegate void TestMethod();
        
        public TestCase(string test_name, TestBase instance) {
            name = test_name;
            test_instance = instance;
        }
        
        public void setup() {
            test_instance.setup();
        }
        
        public void execute() {
            // Test method execution would be handled by subclasses
        }
        
        public void teardown() {
            test_instance.teardown();
        }
    }
}