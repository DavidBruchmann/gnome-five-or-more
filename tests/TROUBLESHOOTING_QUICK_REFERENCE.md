# Five or More - Troubleshooting Quick Reference

## Quick Diagnostic Commands

### Environment Check
```bash
# Validate complete setup
./tests/validate-setup.sh

# Check dependencies
pkg-config --list-all | grep -E "(gtk|glib|gee)"

# Verify build configuration
meson configure builddir-tests | grep -E "(tests|enable)"
```

### Display Issues
```bash
# Check display availability
echo $DISPLAY
xdpyinfo 2>/dev/null || echo "No display - use xvfb-run"

# Use headless testing
xvfb-run -a meson test -C builddir-tests --verbose
```

### Build Problems
```bash
# Clean rebuild
rm -rf builddir-tests
meson setup builddir-tests -Denable_tests=true
meson compile -C builddir-tests
```

## Common Error Solutions

| Error | Quick Fix |
|-------|-----------|
| `Cannot open display` | `xvfb-run -a meson test -C builddir-tests` |
| `Schema not found` | `export GSETTINGS_BACKEND=memory` |
| `Test timeout` | `meson test -C builddir-tests --timeout-multiplier=3` |
| `Build failed` | `rm -rf builddir-tests && meson setup builddir-tests -Denable_tests=true` |
| `Permission denied` | Check file permissions and user access |

## Debug Mode Commands

```bash
# Full debug output
G_MESSAGES_DEBUG=all meson test -C builddir-tests --verbose

# Single test debug
G_MESSAGES_DEBUG=all ./builddir-tests/tests/window-initialization-test

# Memory leak check
valgrind --leak-check=full ./builddir-tests/tests/window-initialization-test
```

## Test-Specific Issues

### Window Tests
- **Dimension mismatch**: Window manager may adjust sizes - check actual vs expected
- **Widget not found**: Verify widget creation order and hierarchy

### Menu Tests  
- **Menu model missing**: Ensure proper GLib.Menu creation and assignment
- **Action not triggered**: Check action registration and signal connections

### Integration Tests
- **Component interaction failure**: Verify proper setup order and dependencies
- **Settings not persisted**: Check mock settings configuration

## Performance Issues

```bash
# Check system resources
uptime && free -h

# Measure test performance
time meson test -C builddir-tests

# Run tests sequentially
meson test -C builddir-tests --num-processes=1
```

## Emergency Recovery

```bash
# Kill hanging processes
killall Xvfb 2>/dev/null || true
killall -9 window-initialization-test 2>/dev/null || true

# Clean temporary files
rm -rf /tmp/.X*-lock 2>/dev/null || true
rm -rf builddir-tests/test-reports/* 2>/dev/null || true

# Reset environment
unset DISPLAY GSETTINGS_BACKEND
export GSETTINGS_BACKEND=memory
```

## Getting Help

1. **Check logs**: `builddir-tests/meson-logs/testlog.txt`
2. **Run with verbose**: Add `--verbose` to any meson test command
3. **Isolate issue**: Run single test to identify specific problem
4. **Check documentation**: See `COMPREHENSIVE_TEST_DOCUMENTATION.md` for detailed guidance