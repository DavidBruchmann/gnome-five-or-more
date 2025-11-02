/*
 * Five or More - Comprehensive Test Runner Main
 * 
 * Main executable for running all window tests with comprehensive reporting.
 */

using FiveOrMoreTest;

namespace FiveOrMoreTest {

    /**
     * Main test runner application
     */
    public class TestRunnerApp : GLib.Object {
        
        private static bool verbose_mode = false;
        private static bool html_report = true;
        private static bool junit_xml = true;
        private static string? build_directory = null;
        private static string? suite_filter = null;
        
        private const OptionEntry[] options = {
            { "verbose", 'v', 0, OptionArg.NONE, ref verbose_mode, "Enable verbose output", null },
            { "no-html", 0, OptionFlags.REVERSE, OptionArg.NONE, ref html_report, "Disable HTML report generation", null },
            { "no-junit", 0, OptionFlags.REVERSE, OptionArg.NONE, ref junit_xml, "Disable JUnit XML report generation", null },
            { "build-dir", 'b', 0, OptionArg.STRING, ref build_directory, "Build directory path", "DIR" },
            { "suite", 's', 0, OptionArg.STRING, ref suite_filter, "Run specific test suite only", "SUITE" },
            { null }
        };
        
        public static int main(string[] args) {
            // Parse command line options
            try {
                var opt_context = new OptionContext("- Five or More Window Test Runner");
                opt_context.set_help_enabled(true);
                opt_context.add_main_entries(options, null);
                opt_context.parse(ref args);
            } catch (OptionError e) {
                printerr("Error parsing options: %s\n", e.message);
                return 1;
            }
            
            // Set default build directory if not specified
            if (build_directory == null) {
                build_directory = "builddir-tests";
            }
            
            print("Five or More - Comprehensive Window Test Runner\n");
            print("===============================================\n");
            print("Build Directory: %s\n", build_directory);
            print("Verbose Mode: %s\n", verbose_mode ? "enabled" : "disabled");
            print("HTML Report: %s\n", html_report ? "enabled" : "disabled");
            print("JUnit XML: %s\n", junit_xml ? "enabled" : "disabled");
            
            if (suite_filter != null) {
                print("Suite Filter: %s\n", suite_filter);
            }
            
            print("\n");
            
            // Check if build directory exists
            if (!FileUtils.test(build_directory, FileTest.IS_DIR)) {
                printerr("Error: Build directory '%s' does not exist.\n", build_directory);
                printerr("Please run 'meson setup %s' first.\n", build_directory);
                return 1;
            }
            
            // Create and configure test runner
            var test_runner = new TestRunner(build_directory);
            test_runner.configure(verbose_mode, html_report, junit_xml);
            
            // Run tests
            TestExecutionSummary summary;
            
            if (suite_filter != null) {
                summary = run_filtered_tests(test_runner, suite_filter);
            } else {
                summary = test_runner.run_all_tests();
            }
            
            // Return appropriate exit code
            return summary.has_failures() ? 1 : 0;
        }
        
        /**
         * Run tests with suite filter
         */
        private static TestExecutionSummary run_filtered_tests(TestRunner runner, string filter) {
            print("Running filtered tests for suite: %s\n", filter);
            
            // For now, we'll run all tests and filter in the summary
            // In a more advanced implementation, we could modify TestRunner to support filtering
            var summary = runner.run_all_tests();
            
            print("Note: Suite filtering applied to results display only.\n");
            print("To implement true filtering, modify TestRunner.setup_test_suites() method.\n");
            
            return summary;
        }
    }
}

