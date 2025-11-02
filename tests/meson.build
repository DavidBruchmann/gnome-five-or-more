# Five or More - Window Testing Framework

# Test dependencies
test_deps = [
  gee_dep,
  gio_dep,
  glib_dep,
  gtk_dep,
  libgnome_games_support_dep,
  librsvg_dep,
  libmath_dep,
]

# Test environment setup
test_env = environment()
test_env.set('G_TEST_SRCDIR', meson.current_source_dir())
test_env.set('G_TEST_BUILDDIR', meson.current_build_dir())
test_env.set('GSETTINGS_BACKEND', 'memory')
test_env.set('GSETTINGS_SCHEMA_DIR', join_paths(meson.project_build_root(), 'data'))

# Xvfb setup for headless GUI testing
xvfb = find_program('xvfb-run', required: false)
if xvfb.found()
  test_env.set('DISPLAY', ':99')
else
  warning('xvfb-run not found, GUI tests may fail in headless environments')
endif

# For now, we'll focus on testing basic window functionality without the full app library
# since it has dependencies on FiveOrMoreApp constants that are complex to mock

# Test utilities and base classes
test_utils_sources = [
  'utils/test-base.vala',
  'utils/mock-settings.vala',
  'utils/test-fixtures.vala',
  'utils/window-test-utils.vala',
]

test_utils_lib = static_library('test-utils',
  test_utils_sources,
  dependencies: test_deps,
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test_utils_dep = declare_dependency(
  link_with: test_utils_lib,
  dependencies: test_deps,
)

# Window initialization tests
window_init_test = executable('window-initialization-test',
  ['window/test-window-initialization.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test('window-initialization',
  window_init_test,
  env: test_env,
  timeout: 30,
)

# Menu system tests
menu_system_test = executable('menu-system-test',
  ['ui/test-menu-system.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test('menu-system',
  menu_system_test,
  env: test_env,
  timeout: 30,
)

# Keyboard shortcut integration tests
keyboard_shortcut_test = executable('keyboard-shortcut-test',
  ['ui/test-keyboard-shortcuts.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test('keyboard-shortcuts',
  keyboard_shortcut_test,
  env: test_env,
  timeout: 30,
)

# Component integration tests
component_integration_test = executable('component-integration-test',
  ['integration/test-component-integration.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test('component-integration',
  component_integration_test,
  env: test_env,
  timeout: 30,
)

# Error handling and logging tests
error_handling_test = executable('error-handling-test',
  ['error/test-error-handling.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

test('error-handling',
  error_handling_test,
  env: test_env,
  timeout: 30,
)

# Comprehensive Test Runner
comprehensive_test_runner = executable('comprehensive-test-runner',
  ['test-runner.vala', 'comprehensive-test-runner.vala'],
  dependencies: [test_utils_dep],
  vala_args: ['--pkg', 'gtk+-3.0', '--pkg', 'gee-0.8'],
  include_directories: config_h_dir,
)

# Note: Accessibility tests are validated through the main application build
# The AccessibilityProfile system is tested as part of the integrated application

# Add comprehensive test runner as a test (optional - can be run manually)
test('comprehensive-runner',
  comprehensive_test_runner,
  args: ['--no-html', '--no-junit'],  # Disable reports for meson test run
  env: test_env,
  timeout: 120,  # Longer timeout for comprehensive testing
)