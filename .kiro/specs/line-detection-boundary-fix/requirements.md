# Line Detection Boundary Fix Requirements

## Introduction

This specification addresses critical boundary bugs in the Five or More game's line detection system that cause incorrect line removal behavior. The bugs manifest as premature line removal (4-piece lines being removed instead of requiring 5) and collision detection failures (interrupted lines being treated as continuous).

## Glossary

- **Game_System**: The Five or More game application
- **Line_Detector**: The component responsible for identifying matching piece sequences
- **Board_Grid**: The logical 2D array storing game pieces
- **Visual_Display**: The graphical representation of the game board
- **Coordinate_System**: The row/column indexing scheme used throughout the application
- **Collision_Detection**: The logic that prevents line formation across different colored pieces
- **Boundary_Validation**: The process of ensuring coordinates are within valid grid bounds

## Requirements

### Requirement 1: Coordinate System Consistency

**User Story:** As a player, I want the game to use consistent coordinate systems so that piece placement and line detection work correctly.

#### Acceptance Criteria

1. WHEN the Game_System initializes a board, THE Game_System SHALL use consistent row/column parameter ordering throughout all components
2. WHEN the Board_Grid is created, THE Game_System SHALL ensure grid dimensions match the intended board size
3. WHEN the Visual_Display is configured, THE Game_System SHALL use the same coordinate system as the Board_Grid
4. WHEN coordinates are passed between components, THE Game_System SHALL maintain consistent row/column ordering
5. THE Game_System SHALL validate that all coordinate access follows the same convention

### Requirement 2: Line Detection Accuracy

**User Story:** As a player, I want lines to be detected accurately so that only valid 5-piece (or longer) lines are removed.

#### Acceptance Criteria

1. WHEN a horizontal line contains exactly 4 matching pieces, THE Line_Detector SHALL NOT remove the line
2. WHEN a horizontal line contains 5 or more matching pieces, THE Line_Detector SHALL remove the line
3. WHEN the Line_Detector evaluates line length, THE Line_Detector SHALL count pieces using correct coordinate mapping
4. WHEN boundary positions are checked, THE Line_Detector SHALL use validated coordinate bounds
5. THE Line_Detector SHALL produce identical results regardless of board size

### Requirement 3: Line Continuity Validation

**User Story:** As a player, I want only truly continuous lines to be detected so that phantom lines and interrupted sequences are not removed.

#### Acceptance Criteria

1. WHEN validating a line, THE Line_Detector SHALL verify every position between start and end contains matching pieces
2. WHEN a line contains empty spaces, THE Line_Detector SHALL NOT treat it as a valid line
3. WHEN a line contains pieces of different colors, THE Line_Detector SHALL treat them as separate segments
4. WHEN calculating line length, THE Line_Detector SHALL count only continuous matching pieces
5. THE Line_Detector SHALL reject phantom lines where only endpoint pieces match

### Requirement 4: Endpoint Matching Prevention

**User Story:** As a player, I want the game to validate entire line sequences so that non-continuous patterns are not treated as valid lines.

#### Acceptance Criteria

1. WHEN checking line validity, THE Line_Detector SHALL validate every position in the sequence
2. WHEN endpoints match but intermediate positions differ, THE Line_Detector SHALL NOT remove the line
3. WHEN gaps exist between matching pieces, THE Line_Detector SHALL treat them as separate segments
4. WHEN counting line length, THE Line_Detector SHALL use piece-by-piece validation instead of coordinate distance
5. THE Line_Detector SHALL prevent removal of phantom lines that appear continuous but are not

### Requirement 5: Boundary Validation

**User Story:** As a player, I want the game to handle board edges correctly so that line detection works properly near boundaries.

#### Acceptance Criteria

1. WHEN checking position validity, THE Game_System SHALL use correct grid dimension bounds
2. WHEN accessing grid positions, THE Game_System SHALL prevent out-of-bounds access
3. WHEN line detection reaches board edges, THE Line_Detector SHALL handle boundaries correctly
4. WHEN coordinates are translated between systems, THE Game_System SHALL maintain position accuracy
5. THE Game_System SHALL validate all coordinate operations against actual grid dimensions

### Requirement 6: Large Board Compatibility

**User Story:** As a player, I want the large board (20x15) to work correctly so that I can play on all difficulty levels.

#### Acceptance Criteria

1. WHEN playing on the large board, THE Game_System SHALL use correct 20-column by 15-row dimensions
2. WHEN the large board is displayed, THE Visual_Display SHALL match the logical grid layout
3. WHEN line detection runs on the large board, THE Line_Detector SHALL use proper coordinate bounds
4. WHEN pieces are placed on the large board, THE Game_System SHALL map visual positions to correct grid coordinates
5. THE Game_System SHALL handle the asymmetric large board dimensions without coordinate confusion

### Requirement 7: Unified Line Detection System

**User Story:** As a player, I want a single, reliable line detection system so that visual feedback always matches piece removal.

#### Acceptance Criteria

1. WHEN line detection is performed, THE Game_System SHALL use a single unified detection engine for both scoring and visual feedback
2. WHEN pieces are removed, THE Game_System SHALL provide visual indication based on the same detection logic used for removal
3. WHEN the unified system detects lines, THE Game_System SHALL provide both removal data and visual feedback data from the same calculation
4. WHEN coordinate fixes are applied, THE Game_System SHALL update the single detection system consistently
5. THE Game_System SHALL eliminate invisible line removal by using one source of truth for all line detection

### Requirement 8: Debug Information Panel

**User Story:** As a developer and player, I want a debugging side panel to understand line detection behavior so that I can verify fixes and troubleshoot issues.

#### Acceptance Criteria

1. WHEN the debug panel is enabled, THE Game_System SHALL display real-time line detection information
2. WHEN a board position is clicked, THE Game_System SHALL show coordinate mapping and line detection results for that position
3. WHEN line detection occurs, THE Game_System SHALL visualize detected lines and highlight any phantom line warnings
4. WHEN coordinate issues are detected, THE Game_System SHALL display boundary validation status and coordinate mismatch alerts
5. THE Game_System SHALL provide export functionality for debug sessions to aid in bug reporting

### Requirement 9: Testing and Validation

**User Story:** As a developer, I want comprehensive tests to verify line detection correctness so that boundary bugs are prevented.

#### Acceptance Criteria

1. WHEN boundary tests are executed, THE Game_System SHALL pass all coordinate consistency checks
2. WHEN line detection tests run, THE unified system SHALL correctly identify valid and invalid lines
3. WHEN collision detection tests execute, THE system SHALL properly handle interrupted sequences
4. WHEN edge case tests are performed, THE Game_System SHALL handle boundary conditions correctly
5. THE Game_System SHALL include automated tests for unified system functionality and all reported bug scenarios