# Color Tooltip Fix

## Issue
The color tooltips in the next pieces preview were showing incorrect color names. For example:
- Orange pieces showed "Cyan" 
- Blue pieces showed "Purple"
- Green pieces showed "Blue"
- And so on...

## Root Cause
The color names array in `src/next-pieces-widget.vala` was not matching the actual color order defined in `src/layered-renderer.vala`.

## Solution
Fixed the color names array to match the correct piece ID to color mapping from the layered renderer.

### Correct Color Mapping
Based on `src/layered-renderer.vala`, the piece colors are defined as:

```vala
private string[] piece_colors = {
    "#FFFF00", // Yellow   - ID 0
    "#FF00FF", // Magenta  - ID 1 (displayed as "Purple")
    "#00FF00", // Green    - ID 2
    "#FF0000", // Red      - ID 3
    "#0000FF", // Blue     - ID 4
    "#00FFFF", // Cyan     - ID 5
    "#FF8000"  // Orange   - ID 6
};
```

### Fixed Color Names Array
Updated `src/next-pieces-widget.vala`:

```vala
// Color names for tooltips - must match the order in layered-renderer.vala
private string[] color_names = {
    _("Yellow"),    // 0: #FFFF00
    _("Purple"),    // 1: #FF00FF (Magenta)
    _("Green"),     // 2: #00FF00
    _("Red"),       // 3: #FF0000
    _("Blue"),      // 4: #0000FF
    _("Cyan"),      // 5: #00FFFF
    _("Orange")     // 6: #FF8000
};
```

## Before vs After

### Before (Incorrect)
- Piece ID 0 (Yellow) → Tooltip showed "Red"
- Piece ID 1 (Purple) → Tooltip showed "Green"
- Piece ID 2 (Green) → Tooltip showed "Blue"
- Piece ID 3 (Red) → Tooltip showed "Yellow"
- Piece ID 4 (Blue) → Tooltip showed "Purple"
- Piece ID 5 (Cyan) → Tooltip showed "Orange"
- Piece ID 6 (Orange) → Tooltip showed "Cyan"

### After (Correct)
- Piece ID 0 (Yellow) → Tooltip shows "Yellow" ✓
- Piece ID 1 (Purple) → Tooltip shows "Purple" ✓
- Piece ID 2 (Green) → Tooltip shows "Green" ✓
- Piece ID 3 (Red) → Tooltip shows "Red" ✓
- Piece ID 4 (Blue) → Tooltip shows "Blue" ✓
- Piece ID 5 (Cyan) → Tooltip shows "Cyan" ✓
- Piece ID 6 (Orange) → Tooltip shows "Orange" ✓

## Testing
1. Launch the game: `./run-five-or-more-with-schema.sh`
2. Hover over next pieces in the header bar
3. Verify tooltip color names match the visual colors

## Files Modified
- `src/next-pieces-widget.vala` - Fixed color names array order
- `NEXT_PIECES_ENHANCEMENT.md` - Updated documentation with correct mapping

The tooltips now correctly identify the piece colors, making the game more accessible and user-friendly!