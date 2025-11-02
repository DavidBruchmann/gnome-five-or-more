/*
 * Five or More - Comprehensive Test Runner
 * 
 * This file provides comprehensive test suite execution framework with
 * result collection, reporting, and performance metrics.
 */

using Gtk;
using GLib;

namespace FiveOrMoreTest {

    /**
     * Test execution result status
     */
    public enum TestStatus {
        NOT_STARTED,
        RUNNING,
        PASSED,
        FAILED,
        SKIPPED,
        ERROR
    }

    /**
     * Performance metrics for test execution
     */
    public class TestMetrics : GLib.Object {
        public double execution_time_ms { get; set; }
        public uint64 memory_usage_kb { get; set; }
        public uint assertions_count { get; set; }
        public uint setup_time_ms { get; set; }
        public uint teardown_time_ms { get; set; }
        
        public TestMetrics() {
            execution_time_ms = 0.0;
            memory_usage_kb = 0;
            assertions_count = 0;
            setup_time_ms = 0;
            teardown_time_ms = 0;
        }
    }

    /**
     * Individual test result with detailed information
     */
    public class TestResult : GLib.Object {
        public string test_name { get; set; }
        public string test_suite { get; set; }
        public TestStatus status { get; set; }
        public string? error_message { get; set; }
        public string? stack_trace { get; set; }
        public TestMetrics metrics { get; set; }
        public DateTime start_time { get; set; }
        public DateTime end_time { get; set; }
        private List<string> _log_messages;
        public unowned List<string> log_messages { 
            get { return _log_messages; }
        }
        
        public void add_log_message(string message) {
            _log_messages.append(message);
        }
        
        public TestResult(string name, string suite) {
            test_name = name;
            test_suite = suite;
            status = TestStatus.NOT_STARTED;
            error_message = null;
            stack_trace = null;
            metrics = new TestMetrics();
            start_time = new DateTime.now_local();
            end_time = new DateTime.now_local();
            _log_messages = new List<string>();
        }
        
        public double get_execution_time_seconds() {
            return end_time.difference(start_time) / 1000000.0; // Convert microseconds to seconds
        }
    }

    /**
     * Test suite configuration and metadata
     */
    public class TestSuiteConfig : GLib.Object {
        public string name { get; set; }
        public string description { get; set; }
        public string executable_path { get; set; }
        public string[] requirements { get; set; }
        public bool enabled { get; set; }
        public uint timeout_seconds { get; set; }
        
        public TestSuiteConfig(string suite_name, string exec_path) {
            name = suite_name;
            description = "";
            executable_path = exec_path;
            requirements = {};
            enabled = true;
            timeout_seconds = 30;
        }
    }

    /**
     * Comprehensive test execution and reporting framework
     */
    public class TestRunner : GLib.Object {
        
        private List<TestSuiteConfig> test_suites;
        private List<TestResult> test_results;
        private string build_directory;
        private string report_directory;
        private bool verbose_output;
        private bool generate_html_report;
        private bool generate_junit_xml;
        
        public TestRunner(string build_dir = "builddir-tests") {
            test_suites = new List<TestSuiteConfig>();
            test_results = new List<TestResult>();
            build_directory = build_dir;
            report_directory = Path.build_filename(build_dir, "test-reports");
            verbose_output = false;
            generate_html_report = true;
            generate_junit_xml = true;
            
            setup_test_suites();
        }
        
        /**
         * Configure test runner options
         */
        public void configure(bool verbose = false, bool html_report = true, bool junit_xml = true) {
            verbose_output = verbose;
            generate_html_report = html_report;
            generate_junit_xml = junit_xml;
        }
        
        /**
         * Set up all available test suites
         */
        private void setup_test_suites() {
            // Window initialization tests
            var window_init_config = new TestSuiteConfig("window-initialization", 
                Path.build_filename(build_directory, "tests", "window-initialization-test"));
            window_init_config.description = "Tests for window creation, initialization, and basic functionality";
            window_init_config.requirements = {"1.1", "1.2", "1.3", "1.4", "1.5"};
            test_suites.append(window_init_config);
            
            // Menu system tests
            var menu_system_config = new TestSuiteConfig("menu-system", 
                Path.build_filename(build_directory, "tests", "menu-system-test"));
            menu_system_config.description = "Tests for hamburger menu functionality and keyboard shortcuts";
            menu_system_config.requirements = {"4.1", "4.2", "4.3", "4.4", "4.5", "5.1", "5.2", "5.3", "5.4", "5.5"};
            test_suites.append(menu_system_config);
            
            // Keyboard shortcut tests
            var keyboard_config = new TestSuiteConfig("keyboard-shortcuts", 
                Path.build_filename(build_directory, "tests", "keyboard-shortcut-test"));
            keyboard_config.description = "Tests for keyboard shortcut functionality and registration";
            keyboard_config.requirements = {"5.1", "5.2", "5.3", "5.4", "5.5"};
            test_suites.append(keyboard_config);
            
            // Component integration tests
            var integration_config = new TestSuiteConfig("component-integration", 
                Path.build_filename(build_directory, "tests", "component-integration-test"));
            integration_config.description = "Tests for component interactions and data flow";
            integration_config.requirements = {"6.1", "6.2", "6.3", "6.4", "6.5"};
            test_suites.append(integration_config);
            
            // Error handling tests
            var error_config = new TestSuiteConfig("error-handling", 
                Path.build_filename(build_directory, "tests", "error-handling-test"));
            error_config.description = "Tests for error handling and logging functionality";
            error_config.requirements = {"7.1", "7.2", "7.3", "7.4", "7.5"};
            test_suites.append(error_config);
        }
        
        /**
         * Run all enabled test suites
         */
        public TestExecutionSummary run_all_tests() {
            print_header("Five or More - Comprehensive Test Execution");
            
            var summary = new TestExecutionSummary();
            summary.start_time = new DateTime.now_local();
            
            // Create report directory
            ensure_report_directory();
            
            // Run each test suite
            foreach (var suite_config in test_suites) {
                if (!suite_config.enabled) {
                    print_info("Skipping disabled test suite: %s", suite_config.name);
                    continue;
                }
                
                print_info("Running test suite: %s", suite_config.name);
                print_info("Description: %s", suite_config.description);
                print_info("Requirements: %s", string.joinv(", ", suite_config.requirements));
                
                var suite_results = run_test_suite(suite_config);
                
                foreach (var result in suite_results) {
                    test_results.append(result);
                    summary.add_result(result);
                }
                
                print_suite_summary(suite_config.name, suite_results);
            }
            
            summary.end_time = new DateTime.now_local();
            
            // Generate reports
            generate_reports(summary);
            
            // Print final summary
            print_execution_summary(summary);
            
            return summary;
        }
        
        /**
         * Run a specific test suite
         */
        public List<TestResult> run_test_suite(TestSuiteConfig config) {
            var results = new List<TestResult>();
            
            if (!FileUtils.test(config.executable_path, FileTest.EXISTS)) {
                var error_result = new TestResult("executable-missing", config.name);
                error_result.status = TestStatus.ERROR;
                error_result.error_message = "Test executable not found: %s".printf(config.executable_path);
                results.append(error_result);
                return results;
            }
            
            try {
                // Execute test suite with timeout
                string stdout_output;
                string stderr_output;
                int exit_status;
                
                var start_time = new DateTime.now_local();
                
                // Set up test environment
                string[] env = setup_test_environment();
                
                bool success = Process.spawn_sync(
                    null, // working directory
                    {config.executable_path, "--verbose"},
                    env,
                    SpawnFlags.SEARCH_PATH,
                    null,
                    out stdout_output,
                    out stderr_output,
                    out exit_status
                );
                
                var end_time = new DateTime.now_local();
                
                if (success) {
                    results = parse_test_output(config.name, stdout_output, stderr_output, exit_status, start_time, end_time);
                } else {
                    var error_result = new TestResult("execution-failed", config.name);
                    error_result.status = TestStatus.ERROR;
                    error_result.error_message = "Failed to execute test suite";
                    results.append(error_result);
                }
                
            } catch (Error e) {
                var error_result = new TestResult("spawn-error", config.name);
                error_result.status = TestStatus.ERROR;
                error_result.error_message = "Error spawning test process: %s".printf(e.message);
                results.append(error_result);
            }
            
            return results;
        }
        
        /**
         * Set up test environment variables
         */
        private string[] setup_test_environment() {
            var env_list = new List<string>();
            
            // Copy current environment
            foreach (string env_var in Environment.list_variables()) {
                env_list.append("%s=%s".printf(env_var, Environment.get_variable(env_var) ?? ""));
            }
            
            // Add test-specific environment variables
            env_list.append("G_TEST_SRCDIR=%s".printf(Path.build_filename(Environment.get_current_dir(), "tests")));
            env_list.append("G_TEST_BUILDDIR=%s".printf(build_directory));
            env_list.append("GSETTINGS_BACKEND=memory");
            env_list.append("GSETTINGS_SCHEMA_DIR=%s".printf(Path.build_filename(build_directory, "data")));
            
            // Set up display for GUI tests
            if (Environment.get_variable("DISPLAY") == null) {
                env_list.append("DISPLAY=:99");
            }
            
            // Convert to array
            string[] env_array = new string[env_list.length()];
            int i = 0;
            foreach (string env_var in env_list) {
                env_array[i++] = env_var;
            }
            
            return env_array;
        }
        
        /**
         * Parse test output and create TestResult objects
         */
        private List<TestResult> parse_test_output(string suite_name, string stdout_output, 
                                                 string stderr_output, int exit_status,
                                                 DateTime start_time, DateTime end_time) {
            var results = new List<TestResult>();
            
            // Parse GLib test output format
            string[] lines = stdout_output.split("\n");
            TestResult? current_result = null;
            
            foreach (string line in lines) {
                string trimmed_line = line.strip();
                
                if (trimmed_line.length == 0) continue;
                
                // Look for test case start
                if (trimmed_line.has_prefix("/")) {
                    // Extract test name from path like "/window/initialization/basic_creation"
                    string test_name = trimmed_line;
                    current_result = new TestResult(test_name, suite_name);
                    current_result.start_time = start_time;
                    current_result.status = TestStatus.RUNNING;
                }
                
                // Look for test results
                if (trimmed_line.contains("OK") && current_result != null) {
                    current_result.status = TestStatus.PASSED;
                    current_result.end_time = end_time;
                    results.append(current_result);
                    current_result = null;
                } else if (trimmed_line.contains("FAIL") && current_result != null) {
                    current_result.status = TestStatus.FAILED;
                    current_result.end_time = end_time;
                    current_result.error_message = trimmed_line;
                    results.append(current_result);
                    current_result = null;
                }
                
                // Collect log messages
                if (current_result != null) {
                    current_result.add_log_message(trimmed_line);
                }
            }
            
            // Handle case where no specific tests were parsed
            if (results.length() == 0) {
                var suite_result = new TestResult("suite-execution", suite_name);
                suite_result.start_time = start_time;
                suite_result.end_time = end_time;
                
                if (exit_status == 0) {
                    suite_result.status = TestStatus.PASSED;
                } else {
                    suite_result.status = TestStatus.FAILED;
                    suite_result.error_message = "Test suite failed with exit code %d".printf(exit_status);
                }
                
                // Add stdout and stderr to log messages
                foreach (string line in stdout_output.split("\n")) {
                    if (line.strip().length > 0) {
                        suite_result.add_log_message("STDOUT: " + line.strip());
                    }
                }
                foreach (string line in stderr_output.split("\n")) {
                    if (line.strip().length > 0) {
                        suite_result.add_log_message("STDERR: " + line.strip());
                    }
                }
                
                results.append(suite_result);
            }
            
            return results;
        }
        
        /**
         * Ensure report directory exists
         */
        private void ensure_report_directory() {
            try {
                var report_dir = File.new_for_path(report_directory);
                if (!report_dir.query_exists()) {
                    report_dir.make_directory_with_parents();
                }
            } catch (Error e) {
                print_error("Failed to create report directory: %s", e.message);
            }
        }
        
        /**
         * Generate all configured reports
         */
        private void generate_reports(TestExecutionSummary summary) {
            print_info("Generating test reports...");
            
            if (generate_html_report) {
                generate_html_report_file(summary);
            }
            
            if (generate_junit_xml) {
                generate_junit_xml_file(summary);
            }
            
            generate_console_report(summary);
        }
        
        /**
         * Generate HTML test report
         */
        private void generate_html_report_file(TestExecutionSummary summary) {
            try {
                string report_path = Path.build_filename(report_directory, "test-report.html");
                var file = File.new_for_path(report_path);
                var output_stream = file.replace(null, false, FileCreateFlags.NONE);
                var data_stream = new DataOutputStream(output_stream);
                
                // Write HTML report
                data_stream.put_string(generate_html_content(summary));
                data_stream.close();
                
                print_info("HTML report generated: %s", report_path);
                
            } catch (Error e) {
                print_error("Failed to generate HTML report: %s", e.message);
            }
        }
        
        /**
         * Generate HTML report content
         */
        private string generate_html_content(TestExecutionSummary summary) {
            var html = new StringBuilder();
            
            html.append("<!DOCTYPE html>\n");
            html.append("<html>\n<head>\n");
            html.append("<title>Five or More - Test Report</title>\n");
            html.append("<style>\n");
            html.append("body { font-family: Arial, sans-serif; margin: 20px; }\n");
            html.append(".header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }\n");
            html.append(".summary { margin: 20px 0; }\n");
            html.append(".passed { color: green; font-weight: bold; }\n");
            html.append(".failed { color: red; font-weight: bold; }\n");
            html.append(".error { color: orange; font-weight: bold; }\n");
            html.append(".skipped { color: gray; font-weight: bold; }\n");
            html.append("table { border-collapse: collapse; width: 100%; margin: 20px 0; }\n");
            html.append("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n");
            html.append("th { background-color: #f2f2f2; }\n");
            html.append(".test-logs { background-color: #f9f9f9; padding: 10px; margin: 10px 0; }\n");
            html.append("</style>\n");
            html.append("</head>\n<body>\n");
            
            // Header
            html.append("<div class='header'>\n");
            html.append("<h1>Five or More - Window Testing Report</h1>\n");
            html.append("<p>Generated: %s</p>\n".printf(new DateTime.now_local().to_string()));
            html.append("</div>\n");
            
            // Summary
            html.append("<div class='summary'>\n");
            html.append("<h2>Test Execution Summary</h2>\n");
            html.append("<p>Total Tests: %u</p>\n".printf(summary.total_tests));
            html.append("<p class='passed'>Passed: %u</p>\n".printf(summary.passed_tests));
            html.append("<p class='failed'>Failed: %u</p>\n".printf(summary.failed_tests));
            html.append("<p class='error'>Errors: %u</p>\n".printf(summary.error_tests));
            html.append("<p class='skipped'>Skipped: %u</p>\n".printf(summary.skipped_tests));
            html.append("<p>Execution Time: %.2f seconds</p>\n".printf(summary.get_total_execution_time()));
            html.append("</div>\n");
            
            // Test Results Table
            html.append("<h2>Test Results</h2>\n");
            html.append("<table>\n");
            html.append("<tr><th>Test Suite</th><th>Test Name</th><th>Status</th><th>Time (s)</th><th>Error Message</th></tr>\n");
            
            foreach (var result in test_results) {
                string status_class = get_status_css_class(result.status);
                html.append("<tr>\n");
                html.append("<td>%s</td>\n".printf(GLib.Markup.escape_text(result.test_suite)));
                html.append("<td>%s</td>\n".printf(GLib.Markup.escape_text(result.test_name)));
                html.append("<td class='%s'>%s</td>\n".printf(status_class, result.status.to_string()));
                html.append("<td>%.3f</td>\n".printf(result.get_execution_time_seconds()));
                html.append("<td>%s</td>\n".printf(GLib.Markup.escape_text(result.error_message ?? "")));
                html.append("</tr>\n");
                
                // Add log messages if available
                if (result.log_messages.length() > 0) {
                    html.append("<tr><td colspan='5'>\n");
                    html.append("<div class='test-logs'>\n");
                    html.append("<strong>Log Messages:</strong><br>\n");
                    foreach (string log_msg in result.log_messages) {
                        html.append("%s<br>\n".printf(GLib.Markup.escape_text(log_msg)));
                    }
                    html.append("</div>\n");
                    html.append("</td></tr>\n");
                }
            }
            
            html.append("</table>\n");
            html.append("</body>\n</html>\n");
            
            return html.str;
        }
        
        /**
         * Get CSS class for test status
         */
        private string get_status_css_class(TestStatus status) {
            switch (status) {
                case TestStatus.PASSED:
                    return "passed";
                case TestStatus.FAILED:
                    return "failed";
                case TestStatus.ERROR:
                    return "error";
                case TestStatus.SKIPPED:
                    return "skipped";
                case TestStatus.RUNNING:
                    return "running";
                case TestStatus.NOT_STARTED:
                    return "not-started";
                default:
                    return "";
            }
        }
        
        /**
         * Generate JUnit XML report
         */
        private void generate_junit_xml_file(TestExecutionSummary summary) {
            try {
                string report_path = Path.build_filename(report_directory, "junit-report.xml");
                var file = File.new_for_path(report_path);
                var output_stream = file.replace(null, false, FileCreateFlags.NONE);
                var data_stream = new DataOutputStream(output_stream);
                
                // Write JUnit XML report
                data_stream.put_string(generate_junit_xml_content(summary));
                data_stream.close();
                
                print_info("JUnit XML report generated: %s", report_path);
                
            } catch (Error e) {
                print_error("Failed to generate JUnit XML report: %s", e.message);
            }
        }
        
        /**
         * Generate JUnit XML content
         */
        private string generate_junit_xml_content(TestExecutionSummary summary) {
            var xml = new StringBuilder();
            
            xml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
            xml.append("<testsuites>\n");
            
            // Group results by test suite
            var suite_groups = new HashTable<string, List<TestResult>>(str_hash, str_equal);
            
            foreach (var result in test_results) {
                if (!suite_groups.contains(result.test_suite)) {
                    suite_groups.set(result.test_suite, new List<TestResult>());
                }
                suite_groups.get(result.test_suite).append(result);
            }
            
            // Generate testsuite elements
            suite_groups.foreach((suite_name, suite_results) => {
                uint suite_tests = suite_results.length();
                uint suite_failures = 0;
                uint suite_errors = 0;
                double suite_time = 0.0;
                
                foreach (var result in suite_results) {
                    suite_time += result.get_execution_time_seconds();
                    if (result.status == TestStatus.FAILED) suite_failures++;
                    if (result.status == TestStatus.ERROR) suite_errors++;
                }
                
                xml.append("<testsuite name=\"%s\" tests=\"%u\" failures=\"%u\" errors=\"%u\" time=\"%.3f\">\n"
                    .printf(GLib.Markup.escape_text(suite_name), suite_tests, suite_failures, suite_errors, suite_time));
                
                foreach (var result in suite_results) {
                    xml.append("<testcase name=\"%s\" classname=\"%s\" time=\"%.3f\">\n"
                        .printf(GLib.Markup.escape_text(result.test_name), 
                               GLib.Markup.escape_text(result.test_suite),
                               result.get_execution_time_seconds()));
                    
                    if (result.status == TestStatus.FAILED) {
                        xml.append("<failure message=\"%s\">%s</failure>\n"
                            .printf(GLib.Markup.escape_text(result.error_message ?? "Test failed"),
                                   GLib.Markup.escape_text(result.error_message ?? "")));
                    } else if (result.status == TestStatus.ERROR) {
                        xml.append("<error message=\"%s\">%s</error>\n"
                            .printf(GLib.Markup.escape_text(result.error_message ?? "Test error"),
                                   GLib.Markup.escape_text(result.error_message ?? "")));
                    }
                    
                    xml.append("</testcase>\n");
                }
                
                xml.append("</testsuite>\n");
            });
            
            xml.append("</testsuites>\n");
            
            return xml.str;
        }
        
        /**
         * Generate console report
         */
        private void generate_console_report(TestExecutionSummary summary) {
            try {
                string report_path = Path.build_filename(report_directory, "console-report.txt");
                var file = File.new_for_path(report_path);
                var output_stream = file.replace(null, false, FileCreateFlags.NONE);
                var data_stream = new DataOutputStream(output_stream);
                
                var report = new StringBuilder();
                
                report.append("Five or More - Window Testing Console Report\n");
                report.append("==========================================\n\n");
                
                report.append("Test Execution Summary:\n");
                report.append("  Total Tests: %u\n".printf(summary.total_tests));
                report.append("  Passed: %u\n".printf(summary.passed_tests));
                report.append("  Failed: %u\n".printf(summary.failed_tests));
                report.append("  Errors: %u\n".printf(summary.error_tests));
                report.append("  Skipped: %u\n".printf(summary.skipped_tests));
                report.append("  Execution Time: %.2f seconds\n\n".printf(summary.get_total_execution_time()));
                
                report.append("Detailed Results:\n");
                report.append("-----------------\n");
                
                foreach (var result in test_results) {
                    report.append("\nTest: %s/%s\n".printf(result.test_suite, result.test_name));
                    report.append("Status: %s\n".printf(result.status.to_string()));
                    report.append("Time: %.3f seconds\n".printf(result.get_execution_time_seconds()));
                    
                    if (result.error_message != null) {
                        report.append("Error: %s\n".printf(result.error_message));
                    }
                    
                    if (result.log_messages.length() > 0) {
                        report.append("Log Messages:\n");
                        foreach (string log_msg in result.log_messages) {
                            report.append("  %s\n".printf(log_msg));
                        }
                    }
                }
                
                data_stream.put_string(report.str);
                data_stream.close();
                
                print_info("Console report generated: %s", report_path);
                
            } catch (Error e) {
                print_error("Failed to generate console report: %s", e.message);
            }
        }
        
        /**
         * Print test suite summary
         */
        private void print_suite_summary(string suite_name, List<TestResult> results) {
            uint passed = 0, failed = 0, errors = 0;
            
            foreach (var result in results) {
                switch (result.status) {
                    case TestStatus.PASSED:
                        passed++;
                        break;
                    case TestStatus.FAILED:
                        failed++;
                        break;
                    case TestStatus.ERROR:
                        errors++;
                        break;
                    case TestStatus.SKIPPED:
                    case TestStatus.RUNNING:
                    case TestStatus.NOT_STARTED:
                        // These are handled in summary counts
                        break;
                }
            }
            
            print_info("Suite '%s' completed: %u passed, %u failed, %u errors", 
                      suite_name, passed, failed, errors);
        }
        
        /**
         * Print final execution summary
         */
        private void print_execution_summary(TestExecutionSummary summary) {
            print_header("Test Execution Complete");
            
            print_info("Total Tests: %u", summary.total_tests);
            print_success("Passed: %u", summary.passed_tests);
            
            if (summary.failed_tests > 0) {
                print_error("Failed: %u", summary.failed_tests);
            }
            
            if (summary.error_tests > 0) {
                print_error("Errors: %u", summary.error_tests);
            }
            
            if (summary.skipped_tests > 0) {
                print_warning("Skipped: %u", summary.skipped_tests);
            }
            
            print_info("Total Execution Time: %.2f seconds", summary.get_total_execution_time());
            
            if (generate_html_report) {
                print_info("HTML Report: %s", Path.build_filename(report_directory, "test-report.html"));
            }
            
            if (generate_junit_xml) {
                print_info("JUnit XML Report: %s", Path.build_filename(report_directory, "junit-report.xml"));
            }
            
            // Exit code based on results
            if (summary.failed_tests > 0 || summary.error_tests > 0) {
                print_error("Some tests failed or had errors!");
            } else {
                print_success("All tests passed successfully!");
            }
        }
        
        // Utility methods for formatted output
        private void print_header(string message) {
            string separator = string.nfill(60, '=');
            print("\n" + separator + "\n");
            print("%s\n", message);
            print(separator + "\n");
        }
        
        private void print_info(string format, ...) {
            var args = va_list();
            print("[INFO] " + format.vprintf(args) + "\n");
        }
        
        private void print_success(string format, ...) {
            var args = va_list();
            print("[SUCCESS] " + format.vprintf(args) + "\n");
        }
        
        private void print_warning(string format, ...) {
            var args = va_list();
            print("[WARNING] " + format.vprintf(args) + "\n");
        }
        
        private void print_error(string format, ...) {
            var args = va_list();
            printerr("[ERROR] " + format.vprintf(args) + "\n");
        }
    }

    /**
     * Test execution summary with aggregated results
     */
    public class TestExecutionSummary : GLib.Object {
        public uint total_tests { get; set; }
        public uint passed_tests { get; set; }
        public uint failed_tests { get; set; }
        public uint error_tests { get; set; }
        public uint skipped_tests { get; set; }
        public DateTime start_time { get; set; }
        public DateTime end_time { get; set; }
        
        public TestExecutionSummary() {
            total_tests = 0;
            passed_tests = 0;
            failed_tests = 0;
            error_tests = 0;
            skipped_tests = 0;
            start_time = new DateTime.now_local();
            end_time = new DateTime.now_local();
        }
        
        public void add_result(TestResult result) {
            total_tests++;
            
            switch (result.status) {
                case TestStatus.PASSED:
                    passed_tests++;
                    break;
                case TestStatus.FAILED:
                    failed_tests++;
                    break;
                case TestStatus.ERROR:
                    error_tests++;
                    break;
                case TestStatus.SKIPPED:
                    skipped_tests++;
                    break;
                case TestStatus.RUNNING:
                case TestStatus.NOT_STARTED:
                    // These states are not counted in final results
                    break;
            }
        }
        
        public double get_total_execution_time() {
            return end_time.difference(start_time) / 1000000.0; // Convert microseconds to seconds
        }
        
        public bool has_failures() {
            return failed_tests > 0 || error_tests > 0;
        }
    }
}