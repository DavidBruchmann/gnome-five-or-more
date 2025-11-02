# Line Detection Boundary Fix Design

## Overview

This design addresses the critical boundary bugs in Five or More's line detection system by establishing coordinate system consistency and implementing a unified line detection architecture. The solution eliminates the problematic dual system approach by creating a single, reliable line detection engine that serves both scoring and visual feedback needs.

## Architecture

### Current Problem Architecture

```
GameDifficulty Array → Board Creation → DUAL LINE DETECTION SYSTEMS
     {n_cols, n_rows}    Board(n_rows, n_cols)           ↓
           ↓                      ↓              Traditional System (Scoring)
    Coordinate Mismatch    Wrong Grid Dimensions    get_all_directions()
                                                           ↓
                                                   INVISIBLE REMOVAL
                                                           ↓
                                                   Composite System (Visual)
                                                   LineDetector class
                                                           ↓
                                                   NEVER RUNS - No Visual Feedback
```

### Fixed Architecture

```
GameDifficulty Array → Coordinate Validator → Board Creation → UNIFIED LINE DETECTION ENGINE
     {n_cols, n_rows}         ↓                Board(n_rows, n_cols)           ↓
           ↓            Consistent Mapping              ↓              Single Source of Truth
    Validated Dimensions    Correct Parameters    Proper Grid Access           ↓
                                                                    Enhanced LineDetector
                                                                           ↓
                                                                   ┌─────────────────┐
                                                                   │  Line Results   │
                                                                   │  - Cells to     │
                                                                   │    Remove       │
                                                                   │  - Visual Data  │
                                                                   │  - Score Info   │
                                                                   └─────────────────┘
                                                                           ↓
                                                                   Consistent Experience
```

## Components and Interfaces

### 1. Coordinate System Validator

**Purpose:** Ensure consistent coordinate usage throughout the application

**Interface:**
```vala
internal class CoordinateValidator : Object {
    public static bool validate_board_dimensions(int size);
    public static bool validate_grid_access(int row, int col, int n_rows, int n_cols);
    public static bool validate_coordinate_consistency(Game game);
}
```

**Responsibilities:**
- Validate GameDifficulty array values
- Check board creation parameters
- Verify grid access bounds
- Ensure visual display matches logical board

### 2. Unified Line Detection Engine

**Purpose:** Single line detection system that serves both scoring and visual needs

**Key Changes:**
```vala
internal class UnifiedLineDetector : Object {
    private Cell[,] grid;
    private int n_rows;
    private int n_cols;
    private CoordinateValidator validator;
    
    // Single method that provides all line detection results
    public LineDetectionResult detect_all_lines(int row, int col);
    
    // Enhanced boundary checking
    private bool is_valid_position(int row, int col);
    
    // Fixed continuity validation (prevents phantom lines)
    private bool validate_line_continuity(int start_row, int start_col, int end_row, int end_col, int piece_type);
    
    // Piece-by-piece validation instead of endpoint matching
    private int count_continuous_pieces(int start_row, int start_col, int dr, int dc, int piece_type);
    
    // Traditional line detection with coordinate fixes
    private Gee.HashSet<Cell> detect_traditional_lines(int row, int col);
    
    // Enhanced line detection for complex patterns
    private Gee.ArrayList<CompositeLine> detect_composite_lines(int row, int col);
}

internal class LineDetectionResult : Object {
    public bool has_lines { get; set; }
    public Gee.HashSet<Cell> cells_to_remove { get; set; }
    public Gee.ArrayList<CompositeLine> visual_lines { get; set; }
    public int score_value { get; set; }
    public string description { get; set; }
    public bool is_traditional { get; set; }
    public bool is_composite { get; set; }
}
```

**Improvements:**
- **Single source of truth** for all line detection
- **Eliminates dual system inconsistencies**
- Proper coordinate validation using actual grid dimensions
- **Phantom line prevention** through piece-by-piece validation
- **Continuity validation** that checks every position in the sequence
- **Endpoint matching prevention** by validating intermediate positions
- **Unified result structure** containing both scoring and visual data
- Consistent coordinate system usage throughout

### 3. Legacy System Migration Manager

**Purpose:** Safely migrate from dual system to unified system while maintaining backward compatibility

**Interface:**
```vala
internal class LegacyMigrationManager : Object {
    public static void replace_traditional_detection(Cell cell, Cell[,] board);
    public static void update_board_integration(Board board);
    public static void migrate_scoring_logic(Game game);
    public static bool validate_migration_success();
}
```

**Responsibilities:**
- Replace calls to get_all_directions() with unified detector
- Update board.vala integration points
- Migrate scoring and visual systems to use unified results
- Validate that migration maintains game functionality

### 4. Board Dimension Manager

**Purpose:** Centralize board dimension management and coordinate mapping

**Interface:**
```vala
internal class BoardDimensionManager : Object {
    public static void get_board_dimensions(int size, out int n_rows, out int n_cols);
    public static bool validate_position(int row, int col, int size);
    public static void map_visual_to_logical(int visual_x, int visual_y, out int logical_row, out int logical_col);
}
```

**Responsibilities:**
- Provide consistent dimension access
- Handle coordinate mapping between visual and logical systems
- Validate all position-based operations

## Data Models

### Fixed GameDifficulty Usage

**Current Issue:**
```vala
// GameDifficulty struct: {n_cols, n_rows, n_types, n_next_pieces}
// But used inconsistently throughout codebase
```

**Solution:**
```vala
// Centralized dimension access
internal struct BoardDimensions {
    public int rows;
    public int cols;
    public int piece_types;
    public int next_pieces;
    
    public static BoardDimensions from_difficulty(int size) {
        var difficulty = Game.game_difficulty[size];
        return BoardDimensions() {
            rows = difficulty.n_rows,    // Explicit mapping
            cols = difficulty.n_cols,    // Explicit mapping
            piece_types = difficulty.n_types,
            next_pieces = difficulty.n_next_pieces
        };
    }
}
```

### Enhanced Line Detection Data

**Continuity-Validated Segment:**
```vala
internal class ContinuousLineSegment : Object {
    public int start_row { get; set; }
    public int start_col { get; set; }
    public int end_row { get; set; }
    public int end_col { get; set; }
    public int length { get; set; }
    public int piece_type { get; set; }
    public bool is_truly_continuous { get; set; }
    public Gee.ArrayList<Cell> validated_pieces { get; set; }
    
    public bool validate_every_position(Cell[,] grid);
    public bool has_gaps_or_foreign_pieces(Cell[,] grid);
    public int count_actual_matching_pieces(Cell[,] grid);
}
```

## Error Handling

### Coordinate Validation Errors

**Strategy:** Fail fast with detailed error information

```vala
internal class CoordinateError : Error {
    public CoordinateError.OUT_OF_BOUNDS(int row, int col, int max_row, int max_col);
    public CoordinateError.DIMENSION_MISMATCH(int expected_rows, int expected_cols, int actual_rows, int actual_cols);
    public CoordinateError.INVALID_MAPPING(string component, string details);
}
```

### Line Detection Error Recovery

**Strategy:** Graceful degradation with logging

```vala
// If coordinate issues detected, fall back to traditional line detection
// Log detailed error information for debugging
// Prevent game crashes while maintaining playability
```

### Boundary Condition Handling

**Strategy:** Defensive programming with validation

```vala
private bool safe_grid_access(int row, int col, out Cell? cell) {
    cell = null;
    if (!is_valid_position(row, col)) {
        warning("Invalid grid access attempted: [%d, %d] on %dx%d grid", row, col, n_rows, n_cols);
        return false;
    }
    cell = grid[row, col];
    return true;
}
```

## Testing Strategy

### Unit Tests

1. **Coordinate Validation Tests**
   - Test all board sizes for dimension consistency
   - Verify coordinate mapping accuracy
   - Validate boundary condition handling

2. **Line Detection Tests**
   - Test exact scenarios reported by users
   - Verify 4-piece lines are NOT removed
   - Confirm 5+ piece lines ARE removed
   - Test collision detection with foreign pieces

3. **Boundary Tests**
   - Test edge cases near board boundaries
   - Verify large board (20x15) coordinate handling
   - Test coordinate translation accuracy

### Integration Tests

1. **End-to-End Game Flow**
   - Complete game sessions on all board sizes
   - Verify visual display matches logical board
   - Test user interaction coordinate mapping

2. **Cross-Component Validation**
   - Test coordinate consistency between components
   - Verify line detection matches visual expectations
   - Validate piece placement accuracy

### Regression Tests

1. **User-Reported Bug Scenarios**
   - 9x9 board, row 4, columns 5-8 (4-piece removal)
   - Large board collision detection failure
   - Any additional reported cases

2. **Edge Case Coverage**
   - Board boundary line detection
   - Maximum length lines
   - Complex collision patterns

## Implementation Phases

### Phase 1: Coordinate System Fix
- Fix GameDifficulty usage consistency
- Implement CoordinateValidator
- Update board creation logic
- Ensure visual display matches logical board

### Phase 2: Line Detection Enhancement
- Fix collision detection logic
- Improve boundary validation
- Enhance segment detection accuracy
- Add comprehensive error handling

### Phase 3: Testing and Validation
- Implement comprehensive test suite
- Validate all reported bug scenarios
- Performance testing on all board sizes
- User acceptance testing

## Design Decisions and Rationales

### Decision 1: Centralized Coordinate Management
**Rationale:** Eliminates coordinate system inconsistencies by providing single source of truth for all coordinate operations.

### Decision 2: Unified Line Detection Architecture
**Rationale:** Eliminates the root cause of invisible line removal by replacing the problematic dual system with a single, reliable line detection engine that serves both scoring and visual needs.

### Decision 3: Phantom Line Prevention Through Continuity Validation
**Rationale:** Addresses the core issue where non-continuous patterns (phantom lines) are incorrectly treated as valid lines by implementing piece-by-piece validation instead of endpoint matching.

### Decision 4: Defensive Programming Approach
**Rationale:** Prevents crashes and provides detailed error information for debugging while maintaining game playability.

### Decision 5: Comprehensive Testing Strategy
**Rationale:** Ensures all reported bugs are fixed and prevents regression of boundary-related issues.

This design provides a robust solution to the boundary bugs while maintaining backward compatibility and improving overall code reliability.