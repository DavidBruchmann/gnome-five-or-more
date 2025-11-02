#!/bin/bash

# Five or More - Test Runner Script
# 
# This script sets up the test environment and runs all window tests.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Five or More - Window Testing Framework${NC}"
echo "========================================"

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
BUILD_DIR="builddir-tests"

echo -e "${YELLOW}Setting up build directory...${NC}"
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning existing build directory..."
    rm -rf "$BUILD_DIR"
fi

# Configure with tests enabled
echo -e "${YELLOW}Configuring build with tests enabled...${NC}"
meson setup "$BUILD_DIR" -Denable_tests=true

# Build the project and tests
echo -e "${YELLOW}Building project and tests...${NC}"
meson compile -C "$BUILD_DIR"

# Run the tests
echo -e "${YELLOW}Running tests...${NC}"
echo "========================================"

if meson test -C "$BUILD_DIR" --verbose; then
    echo "========================================"
    echo -e "${GREEN}✓ All tests passed successfully!${NC}"
else
    echo "========================================"
    echo -e "${RED}✗ Some tests failed. Check the output above for details.${NC}"
    exit 1
fi

# Generate test report if available
if [ -f "$BUILD_DIR/meson-logs/testlog.txt" ]; then
    echo -e "${YELLOW}Test log available at: $BUILD_DIR/meson-logs/testlog.txt${NC}"
fi

echo -e "${GREEN}Testing complete!${NC}"