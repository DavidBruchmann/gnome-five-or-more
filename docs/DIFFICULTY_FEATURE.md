# Five or More - Difficulty Feature Implementation

## Overview

A comprehensive difficulty system has been added to Five or More that allows players to choose between Easy, Normal, and Hard difficulty levels. The main difference between difficulties is the number of pieces added to the board each round.

## Difficulty Levels

| Difficulty | Pieces per Round | Description |
|------------|------------------|-------------|
| **Easy**   | 2 pieces        | Fewer pieces make the game more manageable for beginners |
| **Normal** | 3 pieces        | Default difficulty, balanced gameplay |
| **Hard**   | 4 pieces        | More pieces create a greater challenge |

## Implementation Details

### Core Changes

1. **Game Logic (`src/game.vala`)**:
   - Added `difficulty` property to Game class
   - Created `DifficultyLevel` struct to define difficulty parameters
   - Added `difficulty_levels` constant array with settings for each level
   - Modified `init_game()` to use difficulty-based piece count
   - Added methods: `change_difficulty()`, `get_difficulty_name()`, `get_pieces_per_round()`

2. **User Interface (`src/window.vala`)**:
   - Added `change-difficulty` action to window actions
   - Implemented `change_difficulty()` method to handle difficulty changes
   - Added difficulty initialization in construct method
   - Updated `new_game()` method to respect current difficulty setting

3. **Menu System (`data/ui/five-or-more.ui`)**:
   - Added new "Difficulty" submenu to the hamburger menu
   - Three menu items: Easy, Normal, Hard
   - Each item triggers the `win.change-difficulty` action with appropriate target

4. **Settings (`data/org.gnome.five-or-more.gschema.xml`)**:
   - Added `difficulty` key to store user preference
   - Default value: "normal"
   - Valid values: "easy", "normal", "hard"

5. **Constants (`src/main.vala`)**:
   - Added `KEY_DIFFICULTY` constant for settings key

## User Experience

### How to Change Difficulty

1. Launch Five or More
2. Click the hamburger menu (☰) in the top-right corner
3. Select "Difficulty" from the menu
4. Choose your preferred difficulty level:
   - **Easy**: For a more relaxed experience
   - **Normal**: For balanced gameplay (default)
   - **Hard**: For a greater challenge

### Behavior

- **Immediate Effect**: Changing difficulty immediately starts a new game
- **Persistent Setting**: Your difficulty preference is automatically saved
- **Visual Feedback**: The current difficulty is reflected in the menu selection
- **Game Impact**: Only affects the number of pieces added each round

## Technical Implementation

### Key Files Modified

- `src/game.vala` - Core game logic and difficulty system
- `src/window.vala` - UI integration and settings management
- `src/main.vala` - Settings constants
- `data/ui/five-or-more.ui` - Menu interface
- `data/org.gnome.five-or-more.gschema.xml` - Settings schema

### Backward Compatibility

- Existing save games and settings remain compatible
- Default difficulty is "normal" (3 pieces per round) - same as original behavior
- No changes to board size or other game mechanics

### Code Quality

- ✅ Compiles without errors
- ✅ Follows existing code patterns and style
- ✅ Proper error handling and validation
- ✅ Internationalization support for difficulty names
- ✅ Settings persistence and validation

## Testing

The implementation has been tested for:

- ✅ Correct piece count for each difficulty level
- ✅ Difficulty changes take effect immediately
- ✅ Settings persistence across application restarts
- ✅ Menu integration and user interaction
- ✅ Backward compatibility with existing installations

## Future Enhancements

Potential future improvements could include:

- Custom difficulty settings (user-defined piece count)
- Difficulty-based scoring multipliers
- Achievement system based on difficulty levels
- Statistics tracking per difficulty level

## Installation

To build and install with the new difficulty feature:

```bash
cd builddir
ninja
sudo ninja install
```

The difficulty feature will be immediately available in the hamburger menu after installation.