# Five or More - Configuration System

Five or More now supports a comprehensive configuration system that allows users to customize game behavior, UI elements, and various constants without recompiling the game.

## Overview

The configuration system replaces hardcoded values with configurable constants that can be modified through configuration files. This allows for:

- Customizing game rules (number of pieces needed for a line, piece types, etc.)
- Adjusting board sizes and difficulty levels
- Modifying UI dimensions and behavior
- Tweaking animation timings
- Customizing accessibility settings
- Adjusting scoring algorithms

## Configuration Files

### User Configuration
- **Location**: `~/.config/five-or-more/game-constants.conf`
- **Priority**: Highest (overrides system configuration)
- **Usage**: Personal customizations

### System Configuration
- **Location**: `/etc/five-or-more/game-constants.conf`
- **Priority**: Lower (used if user config doesn't exist)
- **Usage**: System-wide defaults

### Sample Configuration
- **Location**: `/usr/share/five-or-more/examples/game-constants.conf.sample`
- **Usage**: Template for creating custom configurations

## Creating a Configuration File

### Method 1: Command Line
```bash
five-or-more --create-config
```
This creates a sample configuration file at `~/.config/five-or-more/game-constants.conf` with all available options and their default values.

### Method 2: Manual Copy
```bash
mkdir -p ~/.config/five-or-more
cp /usr/share/five-or-more/examples/game-constants.conf.sample ~/.config/five-or-more/game-constants.conf
```

## Configuration Sections

### [GameRules]
Core game mechanics:
- `N_MATCH`: Number of pieces needed to form a line (default: 5)
- `N_TYPES`: Number of different piece types (default: 7)
- `N_ANIMATIONS`: Number of animation frames (default: 4)

**Example**: Make the game easier by requiring only 4 pieces:
```ini
[GameRules]
N_MATCH=4
```

### [BoardSizes]
Board configurations for different sizes:
- `small`: Small board configuration (default: 7,7,5,3)
- `medium`: Medium board configuration (default: 9,9,7,3)
- `large`: Large board configuration (default: 20,15,7,7)

Format: `cols;rows;piece_types;next_pieces`

**Example**: Create a larger medium board:
```ini
[BoardSizes]
medium=12;12;7;4
```

### [Difficulty]
Pieces added per round for each difficulty:
- `easy_pieces`: Easy difficulty (default: 2)
- `normal_pieces`: Normal difficulty (default: 3)
- `hard_pieces`: Hard difficulty (default: 4)

**Example**: Make hard mode even harder:
```ini
[Difficulty]
hard_pieces=6
```

### [UI]
User interface dimensions:
- `MINIMUM_BOARD_SIZE`: Minimum board size in pixels (default: 256)
- `DEBUG_PANEL_WIDTH`: Debug panel width (default: 350)
- `DEBUG_LOG_HEIGHT`: Debug log height (default: 150)
- `MAX_DEBUG_MESSAGES`: Maximum debug messages (default: 100)

### [Scoring]
Score calculation parameters:
- `SCORE_BASE_MULTIPLIER`: Base multiplier (default: 45)
- `SCORE_LOG_FACTOR`: Logarithmic factor (default: 0.25)

**Example**: Make scoring more generous:
```ini
[Scoring]
SCORE_BASE_MULTIPLIER=60
SCORE_LOG_FACTOR=0.35
```

### [Animation]
Animation timing:
- `ANIMATION_DURATION_MS`: Effect duration (default: 1500)
- `ANIMATION_FRAME_MS`: Frame interval (default: 50)
- `ANIMATION_STEP_MS`: Step interval (default: 20)

**Example**: Speed up animations:
```ini
[Animation]
ANIMATION_DURATION_MS=800
ANIMATION_FRAME_MS=25
ANIMATION_STEP_MS=10
```

### [Accessibility]
Accessibility thresholds:
- `WCAG_AA_RATIO`: WCAG AA contrast ratio (default: 4.5)
- `WCAG_AAA_RATIO`: WCAG AAA contrast ratio (default: 7.0)
- `COLORBLIND_THRESHOLD_BASE`: Base colorblind threshold (default: 50.0)
- `COLORBLIND_THRESHOLD_RG`: Red-green colorblind threshold (default: 75.0)

### [Theme]
Theme and rendering:
- `DEFAULT_PIECE_RADIUS`: Default piece radius (default: 37.5)
- `THEME_SPRITE_BASE_SIZE`: Base sprite size (default: 100)
- `SVG_TEMPLATE_WIDTH`: SVG template width (default: 400)
- `SVG_TEMPLATE_HEIGHT`: SVG template height (default: 700)

### [Window]
Window defaults:
- `DEFAULT_WINDOW_WIDTH`: Default width (default: 320)
- `DEFAULT_WINDOW_HEIGHT`: Default height (default: 400)
- `MAX_WINDOW_WIDTH`: Maximum width (default: 4096)
- `MAX_WINDOW_HEIGHT`: Maximum height (default: 4096)

## Validation

Validate your configuration:
```bash
five-or-more --validate-config
```

This checks for:
- Valid value ranges
- Consistent board configurations
- Reasonable UI dimensions
- Proper animation timings

## Examples

### Easy Mode Configuration
Make the game more accessible:
```ini
[GameRules]
N_MATCH=4

[Difficulty]
easy_pieces=1
normal_pieces=2
hard_pieces=3

[BoardSizes]
small=6;6;4;2
medium=8;8;5;2
```

### Speed Gaming Configuration
Faster gameplay:
```ini
[Animation]
ANIMATION_DURATION_MS=500
ANIMATION_FRAME_MS=20
ANIMATION_STEP_MS=5

[Difficulty]
easy_pieces=3
normal_pieces=4
hard_pieces=5
```

### Large Screen Configuration
Optimized for large displays:
```ini
[UI]
MINIMUM_BOARD_SIZE=512
DEBUG_PANEL_WIDTH=450

[Window]
DEFAULT_WINDOW_WIDTH=800
DEFAULT_WINDOW_HEIGHT=600

[Theme]
DEFAULT_PIECE_RADIUS=50
THEME_SPRITE_BASE_SIZE=120
```

## Troubleshooting

### Configuration Not Loading
1. Check file location: `~/.config/five-or-more/game-constants.conf`
2. Verify file permissions (should be readable)
3. Check syntax (use `--validate-config`)
4. Look for error messages in terminal output

### Invalid Values
- Values outside reasonable ranges are ignored
- Check validation output for specific errors
- Refer to default values in sample configuration

### Partial Configuration
- You only need to specify values you want to change
- Unspecified values use defaults
- Empty sections are ignored

## Advanced Usage

### System-wide Configuration
Administrators can create system-wide defaults:
```bash
sudo mkdir -p /etc/five-or-more
sudo cp game-constants.conf.sample /etc/five-or-more/game-constants.conf
sudo nano /etc/five-or-more/game-constants.conf
```

### Multiple Configurations
Create different configuration files for different scenarios:
```bash
# Gaming configuration
cp ~/.config/five-or-more/game-constants.conf ~/.config/five-or-more/gaming.conf

# Accessibility configuration  
cp ~/.config/five-or-more/game-constants.conf ~/.config/five-or-more/accessible.conf

# Switch configurations
cp ~/.config/five-or-more/gaming.conf ~/.config/five-or-more/game-constants.conf
```

## Migration from Hardcoded Values

If you were using a modified version with hardcoded changes, you can now move those customizations to the configuration file:

| Old Hardcoded Location | New Configuration |
|------------------------|-------------------|
| `Game.N_MATCH = 5` | `[GameRules] N_MATCH=5` |
| `Game.game_difficulty` | `[BoardSizes] small=7;7;5;3` |
| `View.MINIMUM_BOARD_SIZE` | `[UI] MINIMUM_BOARD_SIZE=256` |
| Score calculation constants | `[Scoring]` section |
| Animation timings | `[Animation]` section |

This configuration system provides extensive customization while maintaining backward compatibility and reasonable defaults.