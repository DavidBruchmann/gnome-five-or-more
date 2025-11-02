# Five or More - Comprehensive Test Runner Usage Guide

## Overview

The Comprehensive Test Runner provides a unified framework for executing all window tests with detailed reporting and performance metrics collection. It supports HTML reports, JUnit XML output, and console reporting.

## Features

- **Comprehensive Test Execution**: Runs all test suites in sequence
- **Multiple Report Formats**: HTML, JUnit XML, and console reports
- **Performance Metrics**: Execution time tracking and test timing
- **Error Handling**: Graceful handling of test failures and errors
- **Flexible Configuration**: Command-line options for customization
- **Requirements Traceability**: Links test results to specific requirements

## Quick Start

### Using the Shell Script (Recommended)

```bash
# Run all tests with full reporting
./tests/run-comprehensive-tests.sh

# Run with verbose output
./tests/run-comprehensive-tests.sh -v

# Run without generating reports (faster)
./tests/run-comprehensive-tests.sh --no-reports

# Run specific test suite only
./tests/run-comprehensive-tests.sh -s window-initialization

# Get help
./tests/run-comprehensive-tests.sh --help
```

### Using the Executable Directly

```bash
# Build the test runner first
meson compile -C builddir-tests

# Run with default settings
./builddir-tests/tests/comprehensive-test-runner

# Run with custom options
./builddir-tests/tests/comprehensive-test-runner --verbose --build-dir builddir-tests

# Get help
./builddir-tests/tests/comprehensive-test-runner --help
```

## Command Line Options

### Shell Script Options

- `-h, --help`: Show help message
- `-v, --verbose`: Enable verbose output
- `-b, --build-dir DIR`: Specify build directory (default: builddir-tests)
- `-s, --suite SUITE`: Run specific test suite only
- `--no-reports`: Disable HTML and JUnit report generation
- `--setup-only`: Only set up build environment, don't run tests

### Executable Options

- `-v, --verbose`: Enable verbose output
- `--no-html`: Disable HTML report generation
- `--no-junit`: Disable JUnit XML report generation
- `-b, --build-dir=DIR`: Build directory path
- `-s, --suite=SUITE`: Run specific test suite only

## Test Suites

The following test suites are available:

1. **window-initialization**: Tests for window creation, initialization, and basic functionality
   - Requirements: 1.1, 1.2, 1.3, 1.4, 1.5

2. **menu-system**: Tests for hamburger menu functionality and keyboard shortcuts
   - Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5

3. **keyboard-shortcuts**: Tests for keyboard shortcut functionality and registration
   - Requirements: 5.1, 5.2, 5.3, 5.4, 5.5

4. **component-integration**: Tests for component interactions and data flow
   - Requirements: 6.1, 6.2, 6.3, 6.4, 6.5

5. **error-handling**: Tests for error handling and logging functionality
   - Requirements: 7.1, 7.2, 7.3, 7.4, 7.5

## Generated Reports

### HTML Report

- **Location**: `builddir-tests/test-reports/test-report.html`
- **Features**: 
  - Visual test results with color coding
  - Detailed test execution summary
  - Individual test case results with timing
  - Log messages and error details
  - Requirements traceability

### JUnit XML Report

- **Location**: `builddir-tests/test-reports/junit-report.xml`
- **Features**:
  - Standard JUnit XML format
  - Compatible with CI/CD systems
  - Test suite grouping
  - Failure and error details

### Console Report

- **Location**: `builddir-tests/test-reports/console-report.txt`
- **Features**:
  - Plain text format
  - Detailed test results
  - Log messages and error information
  - Execution summary

## Environment Setup

The test runner automatically sets up the required environment:

- **GTK Initialization**: Proper GTK setup for GUI testing
- **Settings Backend**: Memory-based settings to avoid conflicts
- **Display Configuration**: Xvfb support for headless testing
- **Schema Directory**: Proper GSettings schema location

## Performance Metrics

The test runner collects the following metrics:

- **Execution Time**: Total time for each test and test suite
- **Test Counts**: Number of passed, failed, error, and skipped tests
- **Memory Usage**: Basic memory usage tracking (future enhancement)
- **Assertion Counts**: Number of assertions per test (future enhancement)

## Troubleshooting

### Common Issues

1. **Build Directory Not Found**
   ```
   Error: Build directory 'builddir-tests' does not exist.
   ```
   **Solution**: Run `meson setup builddir-tests -Denable_tests=true` first

2. **GUI Tests Failing in Headless Environment**
   ```
   Warning: xvfb-run not found. GUI tests may fail in headless environments.
   ```
   **Solution**: Install xvfb: `sudo apt-get install xvfb` (Ubuntu/Debian)

3. **Test Executable Not Found**
   ```
   Error: Test executable not found: builddir-tests/tests/window-initialization-test
   ```
   **Solution**: Run `meson compile -C builddir-tests` to build tests

### Debug Mode

Enable verbose output to get detailed information:

```bash
./tests/run-comprehensive-tests.sh -v
```

This will show:
- Individual test execution details
- Environment setup information
- Detailed error messages
- Test output and log messages

## Integration with CI/CD

The test runner is designed for CI/CD integration:

1. **Exit Codes**: Returns 0 for success, 1 for failures
2. **JUnit XML**: Standard format for test result reporting
3. **Timeout Handling**: Configurable timeouts for test execution
4. **Environment Variables**: Respects standard testing environment variables

### Example CI Configuration

```yaml
test:
  script:
    - meson setup builddir-tests -Denable_tests=true
    - ./tests/run-comprehensive-tests.sh
  artifacts:
    reports:
      junit: builddir-tests/test-reports/junit-report.xml
    paths:
      - builddir-tests/test-reports/
```

## Extending the Test Runner

### Adding New Test Suites

1. Create the test executable in the meson.build file
2. Add the test suite configuration in `TestRunner.setup_test_suites()`
3. Specify the executable path, description, and requirements

### Custom Report Formats

The TestRunner class can be extended to support additional report formats by:

1. Adding new report generation methods
2. Implementing the report format logic
3. Adding command-line options for the new format

## API Reference

### TestRunner Class

Main class for test execution and reporting.

**Constructor**: `TestRunner(string build_dir = "builddir-tests")`

**Methods**:
- `configure(bool verbose, bool html_report, bool junit_xml)`: Configure options
- `run_all_tests()`: Execute all test suites
- `run_test_suite(TestSuiteConfig config)`: Execute specific test suite

### TestResult Class

Represents individual test results.

**Properties**:
- `test_name`: Name of the test
- `test_suite`: Test suite name
- `status`: Test execution status
- `error_message`: Error message if failed
- `metrics`: Performance metrics
- `log_messages`: Test log messages

### TestExecutionSummary Class

Aggregated test execution results.

**Properties**:
- `total_tests`: Total number of tests
- `passed_tests`: Number of passed tests
- `failed_tests`: Number of failed tests
- `error_tests`: Number of tests with errors
- `skipped_tests`: Number of skipped tests