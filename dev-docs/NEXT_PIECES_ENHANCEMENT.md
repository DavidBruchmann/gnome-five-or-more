# Next Pieces Preview Enhancement

## Overview

Successfully implemented configurable size and tooltip functionality for the next pieces preview in the header bar. The next pieces are now larger, more visible, and provide helpful color information on hover.

## Features Implemented

### 1. Configurable Size
- **Default Size**: Increased from 20px to 24px for better visibility
- **Configurable Range**: 16px to 40px (or any custom size)
- **Configuration Key**: `NEXT_PIECES_SIZE` in Theme section

### 2. Color Name Tooltips
- **Hover Tooltips**: Show color names when hovering over next pieces
- **Multilingual Support**: Color names are translatable using gettext
- **Detailed Information**: Shows both color name and piece position
- **Configuration Key**: `NEXT_PIECES_SHOW_TOOLTIPS` in Theme section

### 3. Accessibility Improvements
- **Larger Visual Elements**: Easier to distinguish colors
- **Text-based Information**: Color names supplement visual cues
- **Keyboard Accessible**: Tooltips work with keyboard navigation
- **Configurable**: Can be disabled if not needed

## Configuration Options

### Size Configuration
```ini
[Theme]
# Size of next pieces preview in header bar in pixels (default: 24)
NEXT_PIECES_SIZE=32
```

**Recommended Sizes:**
- **Small**: 16px - Compact, minimal space usage
- **Default**: 24px - Good balance of size and space
- **Large**: 32px - Better visibility, recommended for accessibility
- **Extra Large**: 40px - Maximum visibility for users with vision difficulties

### Tooltip Configuration
```ini
[Theme]
# Show color names as tooltips on next pieces (default: true)
NEXT_PIECES_SHOW_TOOLTIPS=true
```

## Color Names Supported

The tooltips display localized color names (matching layered-renderer.vala order):
0. **Yellow** - _("Yellow") - #FFFF00
1. **Purple** - _("Purple") - #FF00FF (Magenta)
2. **Green** - _("Green") - #00FF00
3. **Red** - _("Red") - #FF0000
4. **Blue** - _("Blue") - #0000FF
5. **Cyan** - _("Cyan") - #00FFFF
6. **Orange** - _("Orange") - #FF8000

## Tooltip Format

When hovering over a next piece, the tooltip displays:
```
[Color Name]
Next piece [Position]
```

Example: 
```
Red
Next piece 1
```

## Implementation Details

### Code Changes

#### `src/game-constants.vala`
- Added `NEXT_PIECES_SIZE` configuration (default: 24)
- Added `NEXT_PIECES_SHOW_TOOLTIPS` configuration (default: true)
- Updated configuration loading and sample generation

#### `src/next-pieces-widget.vala`
- **Size Management**: Uses configurable `current_sprite_size` instead of hardcoded value
- **Tooltip System**: Added mouse event handling and tooltip generation
- **Color Names**: Integrated translatable color name array
- **Accessibility**: Proper tooltip areas and keyboard support

#### `data/game-constants.conf.sample`
- Added new Theme section options with documentation
- Provided clear examples and default values

### Technical Features

1. **Dynamic Sizing**: Widget automatically adjusts to configured size
2. **Mouse Tracking**: Detects which piece the mouse is hovering over
3. **Tooltip Areas**: Each piece has its own tooltip region
4. **Bounds Checking**: Safe handling of piece IDs and array access
5. **Performance**: Minimal overhead, only active when tooltips enabled

## Usage Examples

### For Better Visibility
```ini
[Theme]
NEXT_PIECES_SIZE=32
NEXT_PIECES_SHOW_TOOLTIPS=true
```

### For Compact Layout
```ini
[Theme]
NEXT_PIECES_SIZE=20
NEXT_PIECES_SHOW_TOOLTIPS=false
```

### For Accessibility
```ini
[Theme]
NEXT_PIECES_SIZE=40
NEXT_PIECES_SHOW_TOOLTIPS=true
```

## Benefits

1. **Improved Visibility**: Larger pieces are easier to see and distinguish
2. **Color Accessibility**: Text-based color information helps colorblind users
3. **User Customization**: Configurable size accommodates different preferences
4. **Better UX**: Tooltips provide helpful information without cluttering UI
5. **Accessibility Compliance**: Supports users with visual difficulties

## Testing

### Automated Testing
- Configuration parsing and loading verified
- Application startup with different sizes tested
- Tooltip system integration confirmed

### Manual Testing
1. **Size Variations**: Test 16px, 24px, 32px, 40px sizes
2. **Tooltip Functionality**: Hover over each next piece position
3. **Color Recognition**: Verify correct color names appear
4. **Configuration Changes**: Test live configuration updates
5. **Accessibility**: Test with screen readers and keyboard navigation

## Configuration File Location

User configuration: `~/.config/five-or-more/game-constants.conf`

## Backward Compatibility

- **Default Behavior**: Slightly larger pieces (24px vs 20px) with tooltips enabled
- **Existing Configs**: Automatically use new defaults if keys not present
- **No Breaking Changes**: All existing functionality preserved

## Future Enhancements

Potential future improvements:
1. **Theme-based Colors**: Different color names for different themes
2. **Custom Color Names**: User-definable color names
3. **Preview Animations**: Subtle animations for next pieces
4. **Position Indicators**: Visual indicators for piece order
5. **Sound Cues**: Audio feedback for accessibility

The next pieces preview is now significantly more accessible and user-friendly, with configurable sizing and helpful tooltips that make the game more enjoyable for all users.