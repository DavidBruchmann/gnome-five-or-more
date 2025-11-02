# Five or More - Window Testing Framework

This directory contains the comprehensive testing framework for the Five or More application window functionality.

## Overview

The testing framework validates:
- Window initialization and component setup
- Window state management and persistence
- HeaderBar functionality and status updates
- Menu system and keyboard shortcuts
- Component integration and data flow
- Error handling and logging

## Architecture

```
tests/
├── utils/                  # Base test classes and utilities
│   ├── test-base.vala     # Base test class with common functionality
│   ├── mock-settings.vala # Mock settings for isolated testing
│   ├── test-fixtures.vala # Reusable test data and configurations
│   └── window-test-utils.vala # Window-specific testing utilities
├── window/                # Window-specific tests
│   ├── test-window-initialization.vala
│   └── test-window-state.vala
├── ui/                    # UI component tests
│   ├── test-headerbar.vala
│   └── test-menu-system.vala
├── integration/           # Integration tests
│   └── test-component-integration.vala
├── error/                 # Error handling tests
│   └── test-error-handling.vala
├── meson.build           # Build configuration for tests
├── run-tests.sh          # Test runner script
└── README.md             # This file
```

## Requirements

### System Dependencies
- GTK+ 3.24 or later
- GLib 2.32 or later
- Meson build system
- Xvfb (for headless GUI testing)

### Installation on Ubuntu/Debian:
```bash
sudo apt-get install xvfb meson valac libgtk-3-dev libglib2.0-dev
```

### Installation on Fedora:
```bash
sudo dnf install xorg-x11-server-Xvfb meson vala gtk3-devel glib2-devel
```

## Running Tests

### Quick Start
```bash
# From project root directory
./tests/run-tests.sh
```

### Manual Build and Test
```bash
# Configure with tests enabled
meson setup builddir-tests -Denable_tests=true

# Build
meson compile -C builddir-tests

# Run tests
meson test -C builddir-tests --verbose
```

### Running Specific Test Suites
```bash
# Run only window initialization tests
meson test -C builddir-tests window-initialization --verbose

# Run only HeaderBar tests
meson test -C builddir-tests headerbar-functionality --verbose

# Run all tests with timeout
meson test -C builddir-tests --timeout-multiplier=2
```

## Test Environment

### Headless Testing
The framework uses Xvfb for headless GUI testing, allowing tests to run in CI/CD environments without a display server.

### Mock Settings
Tests use a mock settings implementation to ensure isolation and prevent interference with user settings.

### Test Fixtures
Predefined test data and configurations are available for consistent testing scenarios.

## Writing New Tests

### Basic Test Structure
```vala
using FiveOrMoreTest;

public class MyTest : TestBase {
    
    public static void main(string[] args) {
        Test.init(ref args);
        Test.add_func("/my/test/case", test_my_functionality);
        Test.run();
    }
    
    public static void test_my_functionality() {
        var test = new MyTest();
        test.setup();
        
        try {
            // Your test code here
            test.test_window.show_all();
            WindowTestUtils.wait_for_window_ready(test.test_window);
            
            // Assertions
            assert_nonnull(test.test_window, "Window should exist");
            
        } finally {
            test.teardown();
        }
    }
}
```

### Using Test Utilities
```vala
// Window operations
WindowTestUtils.simulate_window_resize(window, 800, 600);
WindowTestUtils.simulate_window_maximize(window);
WindowTestUtils.simulate_keyboard_shortcut(window, Gdk.Key.F1, 0);

// Component validation
bool valid = WindowTestUtils.validate_required_components(window);
var headerbar = WindowTestUtils.get_window_headerbar(window);

// Mock settings
SettingsFactory.enable_mock_settings();
var mock = SettingsFactory.get_mock_settings();
mock.setup_window_state(640, 480, false);
```

### Test Fixtures
```vala
// Use predefined window states
var state = TestFixtures.get_default_window_state();
var mock_settings = TestFixtures.create_mock_settings_with_window_state(state);

// Validate against fixtures
bool valid = TestFixtures.validate_window_dimensions(window, state);
```

## Test Categories

### Window Tests (`/window/`)
- Basic window creation and initialization
- Window state management (resize, maximize)
- Settings integration and persistence

### UI Tests (`/ui/`)
- HeaderBar functionality and status updates
- Menu system structure and actions
- Keyboard shortcut handling

### Integration Tests (`/integration/`)
- Component interactions
- Data flow between components
- Theme and settings integration

### Error Handling Tests (`/error/`)
- Graceful error handling
- Logging validation
- Fallback behavior

## Performance Testing

The framework includes utilities for measuring:
- Window creation time
- Resize performance
- Memory usage validation

## Continuous Integration

The test framework is designed to work in CI/CD environments:
- Headless execution with Xvfb
- Isolated test environment
- Comprehensive error reporting
- Performance metrics collection

## Troubleshooting

### Common Issues

1. **Tests fail with "Cannot open display"**
   - Install and use Xvfb: `sudo apt-get install xvfb`
   - Run with: `xvfb-run -a meson test -C builddir-tests`

2. **Build fails with missing dependencies**
   - Install development packages for GTK+ and GLib
   - Check meson configuration: `meson configure builddir-tests`

3. **Tests timeout**
   - Increase timeout: `meson test -C builddir-tests --timeout-multiplier=3`
   - Check system resources and load

### Debug Mode
```bash
# Enable debug output
G_MESSAGES_DEBUG=all meson test -C builddir-tests --verbose

# Run single test with debug
G_MESSAGES_DEBUG=all ./builddir-tests/window-initialization-test
```

## Comprehensive Documentation

For detailed information beyond this overview, see the complete documentation suite:

### 📚 Essential Documentation
- **[COMPREHENSIVE_TEST_DOCUMENTATION.md](COMPREHENSIVE_TEST_DOCUMENTATION.md)** - Complete testing guide with detailed instructions, troubleshooting, and coverage analysis
- **[QUICK_START.md](QUICK_START.md)** - Fast setup and execution guide for immediate use
- **[TEST_RUNNER_USAGE.md](TEST_RUNNER_USAGE.md)** - Advanced test runner features and reporting options

### 🔧 Reference Guides
- **[TROUBLESHOOTING_QUICK_REFERENCE.md](TROUBLESHOOTING_QUICK_REFERENCE.md)** - Quick fixes for common issues and error messages
- **[TEST_COVERAGE_METRICS.md](TEST_COVERAGE_METRICS.md)** - Detailed coverage analysis and performance metrics
- **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Complete documentation navigation guide

### Quick Navigation
- **New to testing?** → Start with [QUICK_START.md](QUICK_START.md)
- **Need detailed guidance?** → See [COMPREHENSIVE_TEST_DOCUMENTATION.md](COMPREHENSIVE_TEST_DOCUMENTATION.md)
- **Having issues?** → Check [TROUBLESHOOTING_QUICK_REFERENCE.md](TROUBLESHOOTING_QUICK_REFERENCE.md)
- **Want coverage details?** → Review [TEST_COVERAGE_METRICS.md](TEST_COVERAGE_METRICS.md)

## Contributing

When adding new tests:
1. Follow the existing test structure and naming conventions
2. Use the provided test utilities and fixtures
3. Ensure tests are isolated and don't depend on external state
4. Add appropriate documentation and comments
5. Update relevant documentation files when adding new test categories
6. See [COMPREHENSIVE_TEST_DOCUMENTATION.md](COMPREHENSIVE_TEST_DOCUMENTATION.md) → "Extending the Test Framework" for detailed guidance

## Requirements Coverage

The test framework validates all requirements from the specification with 100% coverage:
- **Requirements 1.1-1.5**: Window initialization and component setup
- **Requirements 2.1-2.5**: Window state management and persistence
- **Requirements 3.1-3.5**: HeaderBar functionality and status updates
- **Requirements 4.1-4.5**: Menu system structure and functionality
- **Requirements 5.1-5.5**: Keyboard shortcut handling
- **Requirements 6.1-6.5**: Component integration and data flow
- **Requirements 7.1-7.5**: Error handling and logging validation

For detailed coverage analysis and metrics, see [TEST_COVERAGE_METRICS.md](TEST_COVERAGE_METRICS.md).