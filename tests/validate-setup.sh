#!/bin/bash

# Five or More - Test Setup Validation Script
# 
# This script validates that the testing infrastructure is properly set up.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Five or More - Testing Infrastructure Validation${NC}"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "meson.build" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

echo -e "${BLUE}Checking test directory structure...${NC}"

# Check main test directories
directories=(
    "tests"
    "tests/utils"
    "tests/window"
    "tests/ui"
    "tests/integration"
    "tests/error"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} Directory exists: $dir"
    else
        echo -e "${RED}✗${NC} Missing directory: $dir"
        exit 1
    fi
done

echo -e "\n${BLUE}Checking test utility files...${NC}"

# Check utility files
utility_files=(
    "tests/utils/test-base.vala"
    "tests/utils/mock-settings.vala"
    "tests/utils/test-fixtures.vala"
    "tests/utils/window-test-utils.vala"
)

for file in "${utility_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} File exists: $file"
    else
        echo -e "${RED}✗${NC} Missing file: $file"
        exit 1
    fi
done

echo -e "\n${BLUE}Checking test implementation files...${NC}"

# Check test files
test_files=(
    "tests/window/test-window-initialization.vala"
    "tests/window/test-window-state.vala"
    "tests/ui/test-headerbar.vala"
    "tests/ui/test-menu-system.vala"
    "tests/integration/test-component-integration.vala"
    "tests/error/test-error-handling.vala"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} File exists: $file"
    else
        echo -e "${RED}✗${NC} Missing file: $file"
        exit 1
    fi
done

echo -e "\n${BLUE}Checking build configuration files...${NC}"

# Check build files
build_files=(
    "tests/meson.build"
    "meson_options.txt"
)

for file in "${build_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} File exists: $file"
    else
        echo -e "${RED}✗${NC} Missing file: $file"
        exit 1
    fi
done

echo -e "\n${BLUE}Checking documentation and scripts...${NC}"

# Check documentation and scripts
doc_files=(
    "tests/README.md"
    "tests/run-tests.sh"
    "tests/validate-setup.sh"
)

for file in "${doc_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} File exists: $file"
        if [[ "$file" == *.sh ]]; then
            if [ -x "$file" ]; then
                echo -e "${GREEN}  ✓${NC} Script is executable"
            else
                echo -e "${YELLOW}  !${NC} Script is not executable (run: chmod +x $file)"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Missing file: $file"
        exit 1
    fi
done

echo -e "\n${BLUE}Validating meson.build configuration...${NC}"

# Check if tests are properly integrated in main meson.build
if grep -q "enable_tests" meson.build; then
    echo -e "${GREEN}✓${NC} Tests option integrated in main meson.build"
else
    echo -e "${RED}✗${NC} Tests option not found in main meson.build"
    exit 1
fi

if grep -q "subdir('tests')" meson.build; then
    echo -e "${GREEN}✓${NC} Tests subdirectory included in main meson.build"
else
    echo -e "${RED}✗${NC} Tests subdirectory not included in main meson.build"
    exit 1
fi

echo -e "\n${BLUE}Checking for required system dependencies...${NC}"

# Check for system dependencies
dependencies=(
    "valac:Vala compiler"
    "pkg-config:Package config"
)

for dep in "${dependencies[@]}"; do
    cmd="${dep%%:*}"
    desc="${dep##*:}"
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $desc found: $(which $cmd)"
    else
        echo -e "${YELLOW}!${NC} $desc not found: $cmd"
        echo -e "    Install with: sudo apt-get install ${cmd} (Ubuntu/Debian)"
        echo -e "    Install with: sudo dnf install ${cmd} (Fedora)"
    fi
done

# Check for optional dependencies
echo -e "\n${BLUE}Checking for optional dependencies...${NC}"

optional_deps=(
    "meson:Meson build system"
    "xvfb-run:Xvfb for headless testing"
)

for dep in "${optional_deps[@]}"; do
    cmd="${dep%%:*}"
    desc="${dep##*:}"
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $desc found: $(which $cmd)"
    else
        echo -e "${YELLOW}!${NC} $desc not found: $cmd"
        case "$cmd" in
            "meson")
                echo -e "    Install with: sudo apt-get install meson (Ubuntu/Debian)"
                echo -e "    Install with: sudo dnf install meson (Fedora)"
                ;;
            "xvfb-run")
                echo -e "    Install with: sudo apt-get install xvfb (Ubuntu/Debian)"
                echo -e "    Install with: sudo dnf install xorg-x11-server-Xvfb (Fedora)"
                ;;
        esac
    fi
done

echo -e "\n${BLUE}Validating test file syntax...${NC}"

# Basic syntax validation for Vala files
vala_files=$(find tests -name "*.vala" -type f)
syntax_errors=0

for file in $vala_files; do
    # Check for basic syntax issues
    if grep -q "using.*;" "$file" && grep -q "namespace.*{" "$file"; then
        echo -e "${GREEN}✓${NC} Basic syntax OK: $file"
    else
        echo -e "${YELLOW}!${NC} Potential syntax issues in: $file"
        syntax_errors=$((syntax_errors + 1))
    fi
done

if [ $syntax_errors -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All Vala files passed basic syntax check"
else
    echo -e "${YELLOW}!${NC} $syntax_errors files have potential syntax issues"
fi

echo -e "\n${GREEN}=================================================="
echo -e "Testing Infrastructure Validation Complete!${NC}"
echo -e "\n${BLUE}Summary:${NC}"
echo -e "• Test directory structure: ${GREEN}✓ Complete${NC}"
echo -e "• Test utility files: ${GREEN}✓ Complete${NC}"
echo -e "• Test implementation files: ${GREEN}✓ Complete${NC}"
echo -e "• Build configuration: ${GREEN}✓ Complete${NC}"
echo -e "• Documentation: ${GREEN}✓ Complete${NC}"

echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "1. Install missing dependencies if any were reported above"
echo -e "2. Run the tests with: ${YELLOW}./tests/run-tests.sh${NC}"
echo -e "3. Or manually with meson: ${YELLOW}meson setup builddir -Denable_tests=true && meson test -C builddir${NC}"

echo -e "\n${BLUE}For more information, see:${NC} tests/README.md"