# Five or More Enhanced

An enhanced version of the classic GNOME Five or More puzzle game with advanced features, combo mode gameplay,
and comprehensive accessibility support.

## 🎮 Game Overview

Five or More is a strategic puzzle game where you arrange colored balls on a board to form lines and clear them
for points. The goal is to prevent the board from filling up while achieving the highest possible score through
strategic planning and combo formations.

## 📋 Basic Rules

### Traditional Mode
- **Objective**: Form lines of 5 or more balls of the same color
- **Movement**: Click a ball, then click an empty space to move it
- **Line Formation**: Lines can be horizontal, vertical, or diagonal
- **Scoring**: Longer lines earn more points (5 balls = 10 points, 6 balls = 12 points, etc.)
- **New Balls**: After each move, 3 new balls appear randomly on the board
- **Game Over**: When the board fills up and no more moves are possible

### Board Sizes
- **Small**: 7×7 grid (49 spaces)
- **Medium**: 9×9 grid (81 spaces) - Default
- **Large**: 11×11 grid (121 spaces)

### Difficulty Levels
- **Easy**: 2 new balls per turn
- **Normal**: 3 new balls per turn - Default
- **Hard**: 4 new balls per turn

## 🚀 Enhanced Features

### 🎯 Combo Play Mode
**NEW!** An advanced gameplay mode that recognizes gap-separated patterns as valid lines.

**Traditional Line**: `🔴🔴🔴🔴🔴` (5 consecutive balls)

**Combo Patterns**:
- **2+3 Pattern**: `🔴🔴_🔴🔴🔴` (2 balls + gap + 3 balls)
- **3+2 Pattern**: `🔴🔴🔴_🔴🔴` (3 balls + gap + 2 balls)
- **Complex Patterns**: Multiple gaps with strategic arrangements

**Benefits**:
- More strategic depth and planning opportunities
- Higher scoring potential through complex pattern recognition
- Reduced randomness - skill becomes more important
- Extended gameplay sessions with more clearing opportunities

### 📊 Visual Indicators
- **Header Bar Indicator**: Shows when Combo Play Mode is active
- **Menu Checkmark**: Visual confirmation of current mode
- **Mode Transition Notifications**: Clear feedback when switching modes
- **Achievement Notifications**: Celebrate complex combo achievements

### 🎛️ Game Information Panel
Toggle-able side panel providing real-time game analysis:
- **Board State**: Current piece distribution and statistics
- **Move Analysis**: Evaluation of potential moves and outcomes
- **Line Detection**: Preview of possible line formations
- **Strategy Hints**: Suggestions for optimal play
- **Debug Information**: Technical details for advanced users

### ♿ Accessibility Features
- **Screen Reader Support**: Full compatibility with assistive technologies
- **Keyboard Navigation**: Complete keyboard control for all functions
- **High Contrast Modes**: Enhanced visibility options
- **Customizable Themes**: Multiple visual themes (balls, shapes, tango)
- **Tooltips and Descriptions**: Comprehensive help text throughout

## 🎮 How to Play

### Getting Started
1. **Launch**: Find "Five or More Enhanced" in your application menu (Games category)
2. **Choose Mode**: Use the hamburger menu (☰) to toggle "Combo Play" on/off
3. **Select Difficulty**: Choose Easy, Normal, or Hard from the Difficulty menu
4. **Pick Board Size**: Select Small, Medium, or Large from the Size menu

### Basic Gameplay
1. **Select a Ball**: Click on any colored ball to select it
2. **Choose Destination**: Click on an empty space to move the ball
3. **Form Lines**: Arrange 5+ balls of the same color in a line
4. **Clear Lines**: Lines automatically disappear and award points
5. **Continue**: New balls appear after each move - keep clearing lines!

### Advanced Strategies

#### Traditional Mode
- Plan multiple moves ahead to set up longer lines
- Use corners and edges to your advantage
- Block opponent ball placements by strategic positioning
- Focus on clearing multiple lines simultaneously

#### Combo Play Mode
- Look for gap-separated pattern opportunities
- Plan 2+3 and 3+2 formations across the board
- Use gaps strategically to create multiple combo opportunities
- Combine traditional lines with combo patterns for maximum points

### Scoring System
- **5 balls**: 10 points
- **6 balls**: 12 points
- **7 balls**: 18 points
- **8 balls**: 28 points
- **9+ balls**: Exponentially increasing bonuses
- **Combo Patterns**: Bonus multipliers for gap-separated formations
- **Multiple Lines**: Additional bonuses for clearing multiple lines simultaneously

## 🛠️ Installation & Setup

### Quick Start
```bash
# Install desktop entry
./install-desktop-entry.sh

# Launch from application menu or command line
./run-five-or-more-with-schema.sh
```

### Build from Source
```bash
# Build the project
meson setup builddir
cd builddir
ninja

# Run with proper schema support
cd ..
./run-five-or-more-with-schema.sh
```

## ⚙️ Configuration

For detailed configuration options, including:
- Custom game constants and rules
- Advanced accessibility settings
- Developer and debug options
- Theme customization
- Performance tuning

**See: [CONFIGURATION.md](CONFIGURATION.md)**

## 🎯 Game Modes

### Launch Options
```bash
# Normal mode (recommended)
./run-five-or-more-with-schema.sh

# Combo mode enabled by default
./launch-five-or-more.sh combo

# With info panel visible
./launch-five-or-more.sh info

# Debug mode with detailed output
./launch-five-or-more.sh debug
```

## 🏆 Achievements & Scoring

### Traditional Achievements
- **Line Master**: Clear a line of 8+ balls
- **Multi-Clear**: Clear multiple lines in one move
- **Board Cleaner**: Clear 50+ balls in a single game
- **Strategist**: Achieve 1000+ points

### Combo Mode Achievements
- **Combo Novice**: Clear your first 2+3 pattern
- **Pattern Master**: Clear 5 different combo patterns
- **Gap Genius**: Clear a complex multi-gap formation
- **Combo Champion**: Achieve 2000+ points in combo mode

## 🔧 Technical Features

### Performance
- Optimized rendering with layered graphics system
- Efficient line detection algorithms
- Smooth animations and transitions
- Minimal memory footprint

### Accessibility
- Full ARIA label support
- Screen reader announcements
- Keyboard-only navigation
- High contrast theme options
- Customizable UI scaling

### Developer Features
- Comprehensive test suite
- Debug information panel
- Performance monitoring
- Extensible plugin architecture
- Configuration file support

## 📝 Controls

### Mouse Controls
- **Left Click**: Select ball or destination
- **Right Click**: Context menu (future feature)
- **Hover**: Preview move paths and outcomes

### Keyboard Controls
- **Tab**: Navigate between UI elements
- **Enter/Space**: Activate buttons and selections
- **Arrow Keys**: Navigate board positions
- **Escape**: Cancel current selection
- **F1**: Help and keyboard shortcuts
- **Ctrl+N**: New game
- **Ctrl+Q**: Quit application

### Menu Shortcuts
- **F10**: Open hamburger menu
- **Alt+S**: Size submenu
- **Alt+D**: Difficulty submenu
- **Alt+A**: Appearance submenu

## 🐛 Troubleshooting

### Common Issues
- **Schema Error**: Use `./run-five-or-more-with-schema.sh` instead of direct execution
- **Missing Desktop Entry**: Run `./install-desktop-entry.sh` to reinstall
- **Performance Issues**: Check [CONFIGURATION.md](./docs/CONFIGURATION.md) for optimization settings

### Getting Help
- Check the Game Info panel for real-time assistance
- Review [CONFIGURATION.md](./docs/CONFIGURATION.md) for advanced settings
- Use debug mode for detailed diagnostic information

## 🎨 Themes

### Available Themes
- **Balls**: Classic colorful spheres (default)
- **Shapes**: Geometric patterns
- **Tango**: Modern flat design icons

### Customization
- Background color picker
- Custom theme support (see [CONFIGURATION.md](./docs/CONFIGURATION.md))
- High contrast accessibility modes

## 👨‍💻 Developer Documentation

### 🔧 Building & Development

#### Quick Setup
```bash
# Clone and build
git clone <repository-url>
cd five-or-more
meson setup builddir
cd builddir && ninja
```

**Detailed Instructions**: [COMPILE_AND_INSTALL.md](./docs/COMPILE_AND_INSTALL.md)

#### Development Environment
- **Language**: Vala with GTK 3.0
- **Build System**: Meson + Ninja
- **Dependencies**: GTK+3, GLib, LibGnomeGamesSupport, JSON-GLib
- **Schema**: GSettings for configuration management

### 📚 Documentation Index

#### Core Documentation
- **[COMPILE_AND_INSTALL.md](./docs/COMPILE_AND_INSTALL.md)** - Complete build and installation guide
- **[CONFIGURATION.md](./docs/CONFIGURATION.md)** - User and developer configuration options
- **[tests/README.md](tests/README.md)** - Testing framework overview
- **[tests/QUICK_START.md](tests/QUICK_START.md)** - Quick testing guide

#### Testing & Quality Assurance
- **[tests/COMPREHENSIVE_TEST_DOCUMENTATION.md](tests/COMPREHENSIVE_TEST_DOCUMENTATION.md)** - Complete testing guide
- **[tests/TEST_RUNNER_USAGE.md](tests/TEST_RUNNER_USAGE.md)** - Test execution instructions
- **[tests/TEST_COVERAGE_METRICS.md](tests/TEST_COVERAGE_METRICS.md)** - Coverage analysis
- **[tests/TROUBLESHOOTING_QUICK_REFERENCE.md](tests/TROUBLESHOOTING_QUICK_REFERENCE.md)** - Common issues and solutions

#### Feature Documentation
- **[GAME_INFO_PANEL_COMPLETE.md](./docs/GAME_INFO_PANEL_COMPLETE.md)** - Game information panel implementation
- **[DEBUG_PANEL_USAGE.md](./docs/DEBUG_PANEL_USAGE.md)** - Debug panel features and usage
- **[DIFFICULTY_FEATURE.md](./docs/DIFFICULTY_FEATURE.md)** - Difficulty system implementation

#### Architecture & Design
- **[CONFIGURATION_AND_FIXES_SUMMARY.md](./docs/CONFIGURATION_AND_FIXES_SUMMARY.md)** - System overview and fixes
- **[tests/DOCUMENTATION_INDEX.md](tests/DOCUMENTATION_INDEX.md)** - Complete documentation catalog

### 🏗️ Architecture Overview

#### Core Components
```
src/
├── main.vala                    # Application entry point
├── window.vala                  # Main game window
├── game.vala                    # Core game logic
├── board.vala                   # Game board management
├── view.vala                    # Game rendering and UI
├── combo-mode-indicator-manager.vala  # Header bar indicators
├── game-info-panel.vala         # Information panel
├── composite-scoring.vala       # Enhanced scoring system
├── line-detector.vala           # Line detection algorithms
└── accessibility-manager.vala   # Accessibility features
```

#### Key Systems
- **Game Logic**: Traditional and combo mode rule engines
- **Rendering**: Layered graphics with theme support
- **Accessibility**: Full screen reader and keyboard support
- **Configuration**: GSettings-based preference management
- **Testing**: Comprehensive test suite with multiple frameworks

### 🧪 Testing Framework

#### Test Categories
```bash
# Unit tests
./tests/run-tests.sh unit

# Integration tests
./tests/run-tests.sh integration

# UI tests
./tests/run-tests.sh ui

# Comprehensive test suite
./tests/run-comprehensive-tests.sh
```

#### Test Structure
```
tests/
├── unit/                    # Unit tests for individual components
├── integration/             # Integration and system tests
├── ui/                      # User interface tests
├── accessibility/           # Accessibility compliance tests
├── scoring/                 # Scoring system validation
└── utils/                   # Test utilities and fixtures
```

### 🔍 Development Tools

#### Debug Mode
```bash
# Launch with debug information
./launch-five-or-more.sh debug

# Enable game info panel
./launch-five-or-more.sh info

# Comprehensive debugging
GSETTINGS_SCHEMA_DIR=data G_MESSAGES_DEBUG=all ./builddir/src/five-or-more
```

#### Validation Scripts
- **`verify-header-bar-implementation.sh`** - Header bar indicator validation
- **`test-header-bar-indicator.sh`** - Automated indicator testing
- **`show-launch-options.sh`** - Available launch configurations

### 📋 Development Workflow

#### 1. Setup Development Environment
```bash
# Install dependencies (Ubuntu/Debian)
sudo apt install meson ninja-build valac libgtk-3-dev libgee-0.8-dev

# Build project
meson setup builddir
cd builddir && ninja
```

#### 2. Run Tests
```bash
# Quick validation
./tests/validate-setup.sh

# Full test suite
./tests/run-comprehensive-tests.sh

# Specific test categories
./tests/run-tests.sh [unit|integration|ui|accessibility]
```

#### 3. Development Testing
```bash
# Test with proper schema
./run-five-or-more-with-schema.sh

# Debug mode with detailed output
./launch-five-or-more.sh debug

# Validate specific features
./verify-header-bar-implementation.sh
```

### 🎯 Feature Implementation

#### Adding New Features
1. **Design Phase**: Create specification in `.kiro/specs/`
2. **Implementation**: Add source files in `src/`
3. **Testing**: Create tests in `tests/`
4. **Documentation**: Update relevant `.md` files
5. **Integration**: Update build system and schemas

#### Code Style
- **Language**: Vala with GTK conventions
- **Naming**: CamelCase for classes, snake_case for methods
- **Documentation**: Comprehensive inline comments
- **Error Handling**: Graceful degradation with user feedback

### 🔧 Build System

#### Meson Configuration
```bash
# Configure build options
meson configure builddir -Ddebug=true
meson configure builddir -Doptimization=3

# Reconfigure and rebuild
meson setup --reconfigure builddir
```

#### Custom Build Targets
```bash
# Install desktop files
ninja install-desktop-files

# Generate documentation
ninja generate-docs

# Run validation suite
ninja validate-all
```

### 📊 Performance & Profiling

#### Performance Testing
```bash
# Memory usage analysis
valgrind --tool=memcheck ./builddir/src/five-or-more

# Performance profiling
perf record ./builddir/src/five-or-more
perf report
```

#### Optimization Guidelines
- Efficient line detection algorithms
- Minimal memory allocations during gameplay
- Optimized rendering with caching
- Lazy loading of resources

### 🤝 Contributing

#### Development Setup
1. Read [COMPILE_AND_INSTALL.md](./docs/COMPILE_AND_INSTALL.md) for build instructions
2. Review [CONFIGURATION.md](./docs/CONFIGURATION.md) for system understanding
3. Check [tests/README.md](tests/README.md) for testing procedures
4. Follow existing code patterns and documentation standards

#### Pull Request Process
1. Create feature branch from main
2. Implement changes with comprehensive tests
3. Update documentation as needed
4. Ensure all tests pass
5. Submit PR with detailed description

For detailed development procedures, see the complete documentation in the links above.

## 🏅 Credits

Enhanced version built upon the original GNOME Five or More game with additional features:
- Combo Play Mode with gap-separated pattern recognition
- Header bar visual indicators with full accessibility support
- Game Information Panel with real-time analysis
- Enhanced scoring system and achievement tracking
- Comprehensive accessibility improvements
- Advanced configuration and customization options

---

**Enjoy the enhanced Five or More experience!** 🎮✨

For advanced configuration options, see [CONFIGURATION.md](./docs/CONFIGURATION.md)
