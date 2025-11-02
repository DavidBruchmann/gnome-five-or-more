# Five or More - Testing Quick Start Guide

## Prerequisites

Install required dependencies:

### Ubuntu/Debian:
```bash
sudo apt-get install meson valac xvfb libgtk-3-dev libglib2.0-dev libgee-0.8-dev librsvg2-dev libgnome-games-support-1-dev
```

### Fedora:
```bash
sudo dnf install meson vala xorg-x11-server-Xvfb gtk3-devel glib2-devel libgee-devel librsvg2-devel libgnome-games-support-devel
```

## Quick Test Run

1. **Validate setup:**
   ```bash
   ./tests/validate-setup.sh
   ```

2. **Run all tests:**
   ```bash
   ./tests/run-tests.sh
   ```

3. **Manual build and test:**
   ```bash
   meson setup builddir -Denable_tests=true
   meson compile -C builddir
   meson test -C builddir --verbose
   ```

## Test Categories

| Category | Command | Description |
|----------|---------|-------------|
| Window Init | `meson test -C builddir window-initialization` | Basic window creation and setup |
| Window State | `meson test -C builddir window-state-management` | Resize, maximize, state persistence |
| HeaderBar | `meson test -C builddir headerbar-functionality` | Status updates and component integration |
| Menu System | `meson test -C builddir menu-system` | Hamburger menu and keyboard shortcuts |
| Integration | `meson test -C builddir component-integration` | Component interactions and data flow |
| Error Handling | `meson test -C builddir error-handling` | Graceful error handling and logging |

## Common Issues

### "Cannot open display" error:
```bash
# Use Xvfb for headless testing
xvfb-run -a meson test -C builddir --verbose
```

### Build failures:
```bash
# Check dependencies
pkg-config --list-all | grep -E "(gtk|glib|gee)"

# Clean and rebuild
rm -rf builddir
meson setup builddir -Denable_tests=true
```

### Test timeouts:
```bash
# Increase timeout multiplier
meson test -C builddir --timeout-multiplier=3
```

## Requirements Coverage

✅ **Requirements 1.1-1.5**: Window initialization and component setup  
✅ **Requirements 2.1-2.5**: Window state management and persistence  
✅ **Requirements 3.1-3.5**: HeaderBar functionality and status updates  
✅ **Requirements 4.1-4.5**: Menu system structure and functionality  
✅ **Requirements 5.1-5.5**: Keyboard shortcut handling  
✅ **Requirements 6.1-6.5**: Component integration and data flow  
✅ **Requirements 7.1-7.5**: Error handling and logging validation  

## Next Steps

- See `tests/README.md` for detailed documentation
- Check individual test files for specific test cases
- Use test utilities in `tests/utils/` for custom tests