#!/bin/bash

# Five or More - Comprehensive Test Runner Script
# 
# This script runs the comprehensive test runner with full reporting capabilities.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_DIR="builddir-tests"
VERBOSE=false
SUITE_FILTER=""
GENERATE_REPORTS=true

# Function to display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --verbose           Enable verbose output"
    echo "  -b, --build-dir DIR     Specify build directory (default: builddir-tests)"
    echo "  -s, --suite SUITE       Run specific test suite only"
    echo "  --no-reports            Disable HTML and JUnit report generation"
    echo "  --setup-only            Only set up build environment, don't run tests"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests with default settings"
    echo "  $0 -v                   # Run with verbose output"
    echo "  $0 -s window-initialization  # Run only window initialization tests"
    echo "  $0 --no-reports         # Run tests without generating reports"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -b|--build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        -s|--suite)
            SUITE_FILTER="$2"
            shift 2
            ;;
        --no-reports)
            GENERATE_REPORTS=false
            shift
            ;;
        --setup-only)
            SETUP_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Five or More - Comprehensive Window Test Runner${NC}"
echo "================================================"

# Check if we're in the right directory
if [ ! -f "meson.build" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

# Check for required dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"

# Check for Xvfb
if ! command -v xvfb-run &> /dev/null; then
    echo -e "${YELLOW}Warning: xvfb-run not found. GUI tests may fail in headless environments.${NC}"
    echo "To install on Ubuntu/Debian: sudo apt-get install xvfb"
    echo "To install on Fedora: sudo dnf install xorg-x11-server-Xvfb"
fi

# Check for meson
if ! command -v meson &> /dev/null; then
    echo -e "${RED}Error: meson not found. Please install meson build system.${NC}"
    exit 1
fi

# Set up build directory
echo -e "${YELLOW}Setting up build directory: $BUILD_DIR${NC}"
if [ -d "$BUILD_DIR" ]; then
    echo "Using existing build directory..."
else
    echo "Creating new build directory..."
    meson setup "$BUILD_DIR" -Denable_tests=true
fi

# Build the project and tests
echo -e "${YELLOW}Building project and comprehensive test runner...${NC}"
meson compile -C "$BUILD_DIR"

# Exit if setup-only was requested
if [ "$SETUP_ONLY" = true ]; then
    echo -e "${GREEN}Build setup complete. Test runner available at: $BUILD_DIR/tests/comprehensive-test-runner${NC}"
    exit 0
fi

# Prepare test runner arguments
RUNNER_ARGS=()

if [ "$VERBOSE" = true ]; then
    RUNNER_ARGS+=("--verbose")
fi

if [ "$GENERATE_REPORTS" = false ]; then
    RUNNER_ARGS+=("--no-html" "--no-junit")
fi

if [ -n "$SUITE_FILTER" ]; then
    RUNNER_ARGS+=("--suite" "$SUITE_FILTER")
fi

RUNNER_ARGS+=("--build-dir" "$BUILD_DIR")

# Run the comprehensive test runner
echo -e "${YELLOW}Running comprehensive test suite...${NC}"
echo "========================================"

# Set up environment for GUI testing
export GSETTINGS_BACKEND=memory
export GSETTINGS_SCHEMA_DIR="$BUILD_DIR/data"

# Run with or without Xvfb depending on availability
if command -v xvfb-run &> /dev/null && [ -z "$DISPLAY" ]; then
    echo "Running tests with Xvfb (headless mode)..."
    if xvfb-run -a "$BUILD_DIR/tests/comprehensive-test-runner" "${RUNNER_ARGS[@]}"; then
        TEST_EXIT_CODE=0
    else
        TEST_EXIT_CODE=$?
    fi
else
    echo "Running tests with current display..."
    if "$BUILD_DIR/tests/comprehensive-test-runner" "${RUNNER_ARGS[@]}"; then
        TEST_EXIT_CODE=0
    else
        TEST_EXIT_CODE=$?
    fi
fi

echo "========================================"

# Report results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests completed successfully!${NC}"
    
    if [ "$GENERATE_REPORTS" = true ]; then
        echo ""
        echo -e "${BLUE}Generated Reports:${NC}"
        if [ -f "$BUILD_DIR/test-reports/test-report.html" ]; then
            echo -e "  HTML Report: ${BLUE}$BUILD_DIR/test-reports/test-report.html${NC}"
        fi
        if [ -f "$BUILD_DIR/test-reports/junit-report.xml" ]; then
            echo -e "  JUnit XML: ${BLUE}$BUILD_DIR/test-reports/junit-report.xml${NC}"
        fi
        if [ -f "$BUILD_DIR/test-reports/console-report.txt" ]; then
            echo -e "  Console Report: ${BLUE}$BUILD_DIR/test-reports/console-report.txt${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Some tests failed or had errors. Check the output above for details.${NC}"
    
    if [ "$GENERATE_REPORTS" = true ]; then
        echo ""
        echo -e "${YELLOW}Check the generated reports for detailed failure information:${NC}"
        if [ -f "$BUILD_DIR/test-reports/test-report.html" ]; then
            echo -e "  HTML Report: ${BLUE}$BUILD_DIR/test-reports/test-report.html${NC}"
        fi
    fi
fi

# Show meson test log if available
if [ -f "$BUILD_DIR/meson-logs/testlog.txt" ]; then
    echo -e "${YELLOW}Meson test log available at: $BUILD_DIR/meson-logs/testlog.txt${NC}"
fi

echo -e "${GREEN}Comprehensive testing complete!${NC}"
exit $TEST_EXIT_CODE