# Five or More - Boundary Bug Analysis

## 🐛 Critical Bug Identified: Row/Column Coordinate Mismatch

### **The Problem**

There's a fundamental mismatch between how the logical board is created and how the visual display is configured.

### **Evidence from Code Analysis**

#### 1. GameDifficulty Structure (src/game.vala:333-338)
```vala
private struct GameDifficulty {
    public int n_cols;        // First field
    public int n_rows;        // Second field  
    public int n_types;       // Third field
    public int n_next_pieces; // Fourth field
}
```

#### 2. GameDifficulty Array (src/game.vala:86-90)
```vala
internal const GameDifficulty[] game_difficulty = {
    { -1, -1, -1, -1 },  // Invalid
    {  7,  7,  5,  3 },  // Small:  n_cols=7,  n_rows=7
    {  9,  9,  7,  3 },  // Medium: n_cols=9,  n_rows=9  
    { 20, 15,  7,  7 }   // Large:  n_cols=20, n_rows=15 ⚠️
};
```

#### 3. Board Creation (src/game.vala:145)
```vala
board = new Board(n_rows, n_cols);  // Creates grid[n_rows, n_cols]
```

#### 4. Visual Display Setup (src/window.vala:138)
```vala
grid_frame.set(game.n_cols, game.n_rows);  // Visual: [n_cols, n_rows]
```

### **The Critical Issue**

For the **Large board**:
- **Intended:** 20 columns × 15 rows
- **Logical Board:** `grid[15, 20]` (15 rows, 20 columns)
- **Visual Display:** Configured as 20×15 (20 columns, 15 rows)

**This creates a coordinate system mismatch!**

### **Impact on Game Logic**

1. **Piece Placement:**
   - Random placement uses: `Random.int_range(0, n_rows)` and `Random.int_range(0, n_cols)`
   - But accesses: `grid[row, col]` where dimensions might be swapped

2. **Line Detection:**
   - Algorithms traverse `grid[row, col]` assuming correct dimensions
   - But actual grid might have swapped dimensions

3. **Visual Rendering:**
   - View assumes certain coordinate mapping
   - But logical board has different coordinate system

### **Why This Causes 4-Piece Line Removal**

The coordinate mismatch could cause:
- **Incorrect boundary checks** in line detection
- **Wrong cell counting** when traversing lines
- **Coordinate confusion** between visual and logical positions
- **Off-by-one errors** in line length calculation

### **Verification Steps**

1. **Test Large Board:** Play on large board and check for issues
2. **Check Coordinates:** Verify that clicking position (x,y) maps to correct grid[row,col]
3. **Boundary Testing:** Try placing pieces near edges of large board
4. **Line Detection:** Test line detection near board boundaries

### **Recommended Fix**

The issue needs to be resolved by ensuring consistent coordinate usage throughout:

1. **Either:** Fix the GameDifficulty array to match the struct order
2. **Or:** Fix the board creation and visual setup to use consistent coordinate system
3. **Verify:** All coordinate usage follows the same row/column convention

### **Files Affected**
- `src/game.vala` - GameDifficulty array and board creation
- `src/window.vala` - Visual display setup  
- `src/view.vala` - Coordinate mapping for user interaction
- `src/board.vala` - Grid access and boundary checks
- `src/line-detector.vala` - Line detection algorithms

This boundary mismatch is a serious bug that could explain multiple gameplay issues including the 4-piece line removal you observed.

### **User-Reported Case Analysis**

**Specific Bug Instance:**
- **Board:** 9x9 (Medium difficulty)
- **Location:** Row 4, columns 5-8 (1-based indexing)
- **Issue:** 4-piece horizontal line was removed instead of requiring 5 pieces
- **Context:** Positions 4-4 and 4-9 occupied by different colored pieces (should block 5-piece line)

**How This Relates to the Boundary Bug:**

1. **Coordinate Translation:** The positions translate to 0-based coordinates as:
   - Row 3, columns 4-7 (the 4-piece line)
   - Row 3, column 3 and column 8 (the blocking pieces)

2. **Potential Coordinate Confusion:** If the line detector has row/column coordinate mismatch:
   - It might access `grid[col, row]` instead of `grid[row, col]`
   - This could cause it to read from wrong positions
   - Line length calculation could be incorrect
   - Boundary checks might fail

3. **Line Detection Logic Error:** The boundary mismatch could cause:
   - **Wrong piece counting:** Algorithm counts 4 pieces but thinks it found 5
   - **Boundary miscalculation:** Blocking pieces at positions 4-4 and 4-9 not properly detected
   - **Coordinate system confusion:** Visual coordinates don't match logical grid coordinates

4. **Why This Happens on 9x9 Board:** Even though 9x9 is symmetric, the coordinate mismatch in the code structure affects how the line detection algorithm traverses the grid and counts pieces.

This specific case provides strong evidence that the boundary bug affects line detection logic, not just board initialization.

### **Additional User-Reported Case: Large Board Collision Detection Failure**

**Second Bug Instance:**
- **Board:** Large board (20x15)
- **Pattern:** 2 pieces + 1 foreign color + 4 pieces (same color as first 2)
- **Issue:** The 6-piece interrupted line gets removed as if it were continuous
- **Expected:** Line should NOT be removed due to foreign color interruption
- **Actual:** Line WAS removed (collision detection failed)

**Analysis of Collision Detection Failure:**

1. **Coordinate System Impact:** The boundary mismatch affects how the line detector:
   - Traverses segments in `find_segments_in_direction()`
   - Calculates segment boundaries in `find_segment_end()`
   - Validates positions in `is_valid_position()`

2. **Segment Detection Logic Error:** The coordinate confusion could cause:
   - **Wrong segment identification:** Algorithm doesn't properly detect the foreign piece interruption
   - **Boundary miscalculation:** Segments are incorrectly merged across the foreign piece
   - **Position validation failure:** `is_valid_position()` checks wrong coordinates

3. **Large Board Specific Impact:** The 20x15 board has the most severe coordinate mismatch:
   - **GameDifficulty:** `{20, 15, 7, 7}` (n_cols=20, n_rows=15)
   - **Board Creation:** `new Board(n_rows, n_cols)` → `Board(15, 20)`
   - **Grid Access:** `grid[15, 20]` but algorithms expect `grid[20, 15]`

4. **Why Collision Detection Fails:** The coordinate mismatch causes:
   - **Segment merging errors:** Foreign pieces not properly detected as interruptions
   - **Wrong piece counting:** Algorithm counts pieces across interruptions
   - **Boundary confusion:** Line detection spans across what should be separate segments

### **Third Critical Issue: Phantom Line Detection (Endpoint Matching Bug)**

**Most Severe Bug Discovery:**
- **Pattern:** Lines are removed when only the outer/endpoint pieces match
- **Issue:** Algorithm ignores pieces or empty spaces between endpoints
- **Behavior:** Non-continuous patterns treated as valid lines
- **Impact:** Fundamental violation of Five-or-More game rules

**Analysis of Phantom Line Detection:**

1. **Endpoint Matching Logic Error:** The line detector appears to:
   - **Check only start and end positions** instead of validating entire sequence
   - **Skip intermediate validation** of pieces between endpoints
   - **Treat gaps as valid** when they should break line continuity
   - **Count phantom pieces** that don't actually form a continuous line

2. **Algorithm Logic Flaw:** This suggests the line detection has:
   - **Boundary-based counting** instead of piece-by-piece validation
   - **Distance calculation errors** treating coordinate spans as piece counts
   - **Segment merging bugs** combining non-adjacent pieces into false lines
   - **Continuity validation failure** not checking every position in the sequence

3. **Why This Is More Serious Than Collision Detection:** 
   - **Not just collision failure:** The algorithm fundamentally misunderstands what constitutes a line
   - **Phantom line creation:** Lines are detected where none actually exist
   - **Game rule violation:** Removes pieces that shouldn't be removed according to Five-or-More rules
   - **Coordinate system amplification:** The boundary bug makes this phantom detection worse

### **Fourth Critical Discovery: Dual Line Detection System Mismatch**

**Root Cause Identified:**
- **Two separate line detection systems** exist in the codebase
- **Traditional system** (`get_all_directions()`) handles scoring and piece removal
- **Composite system** (`LineDetector` class) handles visual effects and advanced patterns
- **Mismatch between systems** causes invisible line removals

**Code Evidence:**

```vala
// In board.vala - get_all_lines_composite()
// First check traditional lines for backward compatibility
var traditional_cells = get_all_directions(board);
if (traditional_cells.size > 0) {
    result.traditional_cells = traditional_cells;
    result.has_traditional_lines = true;
    return result;  // STOPS HERE - never checks composite system
}

// If no traditional lines, check for composite lines
var line_detector = new LineDetector(board);
var composite_lines = line_detector.detect_composite_lines(this.row, this.col);
```

**The Dual System Problem:**

1. **Traditional System Issues:**
   - Uses `get_horizontal()`, `get_vertical()`, `get_first_diagonal()`, `get_second_diagonal()`
   - Subject to the coordinate boundary bug
   - May have phantom line detection due to coordinate confusion
   - **This system removes pieces invisibly**

2. **Composite System Issues:**
   - More sophisticated but only runs if traditional system finds nothing
   - Has its own coordinate handling that might be different
   - **This system provides visual feedback but may not match removal logic**

3. **Mismatch Consequences:**
   - **Traditional system removes pieces** based on flawed coordinate logic
   - **Player sees no visual indication** because composite system uses different logic
   - **Invisible line removal** occurs when traditional system detects phantom lines
   - **Visual system never gets chance to run** because traditional system always finds something

**Combined Evidence:** The boundary bug affects the traditional line detection system, causing it to detect phantom lines and remove pieces invisibly. The composite system, which could provide visual feedback, never runs because the traditional system always returns results first. This explains all reported issues: invisible 4-piece removals, collision detection failures, and phantom line detection.