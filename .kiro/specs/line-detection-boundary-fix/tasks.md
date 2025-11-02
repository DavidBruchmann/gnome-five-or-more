# Line Detection Boundary Fix Implementation Plan

- [x] 1. Create coordinate validation infrastructure
  - Implement CoordinateValidator class with dimension validation methods
  - Add BoardDimensionManager for centralized dimension access
  - Create coordinate error handling classes
  - _Requirements: 1.1, 1.4, 4.1, 4.2_

- [ ] 2. Fix GameDifficulty coordinate consistency
  - [x] 2.1 Analyze current GameDifficulty array usage patterns
    - Document all locations where GameDifficulty values are accessed
    - Identify coordinate parameter ordering inconsistencies
    - Map coordinate flow from GameDifficulty to Board creation to Visual display
    - _Requirements: 1.1, 1.3_

  - [ ] 2.2 Implement BoardDimensions wrapper structure
    - Create BoardDimensions struct with explicit row/col mapping
    - Add from_difficulty() static method for safe dimension extraction
    - Replace direct GameDifficulty access with BoardDimensions usage
    - _Requirements: 1.1, 1.2_

  - [ ] 2.3 Update board creation logic
    - Fix Board constructor parameter ordering to match intended dimensions
    - Ensure grid creation uses correct row/column dimensions
    - Validate board creation against intended board sizes
    - _Requirements: 1.2, 5.1_

- [ ] 3. Enhance line detection boundary validation
  - [ ] 3.1 Fix is_valid_position() method in LineDetector
    - Update boundary checks to use actual grid dimensions
    - Add coordinate validation logging for debugging
    - Implement safe grid access with bounds checking
    - _Requirements: 4.1, 4.3_

  - [x] 3.2 Implement phantom line prevention
    - Fix find_segment_end() to validate every position in the sequence
    - Replace endpoint matching with piece-by-piece continuity validation
    - Add validate_line_continuity() method to check intermediate positions
    - Prevent removal of lines where only endpoints match
    - _Requirements: 3.1, 3.2, 4.1, 4.2_

  - [ ] 3.3 Implement piece-by-piece counting instead of coordinate distance
    - Replace calculate_segment_length() with count_continuous_pieces()
    - Count only actual matching pieces, not coordinate spans
    - Ensure line detection only removes truly continuous 5+ piece lines
    - Add validation that phantom lines and 4-piece lines are never removed
    - _Requirements: 2.1, 2.2, 2.3, 4.3, 4.4_

- [ ] 4. Fix large board coordinate handling
  - [ ] 4.1 Correct large board (20x15) dimension mapping
    - Fix coordinate system for asymmetric board dimensions
    - Ensure visual display matches logical 20-column by 15-row layout
    - Update coordinate translation for large board user interactions
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ] 4.2 Validate large board line detection
    - Test line detection algorithms on 20x15 grid
    - Fix any coordinate access issues specific to large board
    - Ensure phantom line prevention works correctly on large board
    - Test continuity validation across the asymmetric board dimensions
    - _Requirements: 5.3, 5.4, 6.3_

- [ ] 5. Implement comprehensive boundary testing
  - [ ] 5.1 Create comprehensive line detection bug test suite
    - Implement tests for user-reported 9x9 board scenario (row 4, columns 5-8)
    - Add tests for large board phantom line detection
    - Create tests for endpoint matching prevention (non-continuous patterns)
    - Test scenarios where only outer pieces match but intermediate positions differ
    - Create edge case tests for all board sizes
    - _Requirements: 6.1, 6.2, 6.5, 7.1, 7.5_

  - [ ] 5.2 Add coordinate consistency validation tests
    - Test coordinate mapping between visual and logical systems
    - Validate grid access bounds for all board sizes
    - Test boundary condition handling at board edges
    - _Requirements: 6.1, 6.4_

  - [ ]* 5.3 Create automated regression tests
    - Implement continuous testing for reported bug scenarios
    - Add performance tests for line detection on all board sizes
    - Create integration tests for complete game flow validation
    - _Requirements: 6.3, 6.5_

- [ ] 6. Update visual display coordinate mapping
  - [ ] 6.1 Fix window.vala grid_frame configuration
    - Ensure grid_frame.set() uses consistent coordinate ordering
    - Match visual display dimensions to logical board dimensions
    - Fix coordinate mapping for user click interactions
    - _Requirements: 1.3, 5.2_

  - [ ] 6.2 Validate view.vala coordinate translation
    - Fix coordinate mapping between user clicks and grid positions
    - Ensure visual positions correctly map to logical board coordinates
    - Test coordinate accuracy on all board sizes
    - _Requirements: 1.4, 5.4_

- [ ] 7. Implement unified line detection system
  - [x] 7.1 Create UnifiedLineDetector class
    - Design single line detection engine that replaces both traditional and composite systems
    - Implement detect_all_lines() method that returns comprehensive LineDetectionResult
    - Include both traditional line detection logic and composite pattern detection
    - Apply all coordinate fixes and phantom line prevention to unified system
    - _Requirements: 7.1, 7.3, 7.5_

  - [ ] 7.2 Migrate traditional line detection logic
    - Extract and fix coordinate issues from get_horizontal(), get_vertical(), get_first_diagonal(), get_second_diagonal()
    - Integrate corrected traditional detection into UnifiedLineDetector
    - Ensure piece-by-piece validation instead of coordinate distance calculation
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 7.1_

  - [x] 7.3 Replace dual system calls with unified system
    - Update board.vala get_all_lines_composite() to use UnifiedLineDetector
    - Replace get_all_directions() calls with unified detection
    - Ensure single source of truth for all line detection throughout codebase
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 7.4 Eliminate invisible line removal
    - Ensure unified system provides both removal data and visual feedback data
    - Remove conditional logic that chooses between traditional and composite systems
    - Guarantee visual feedback for all line removals through unified results
    - _Requirements: 7.1, 7.5_

- [ ] 8. Implement debugging side panel
  - [x] 8.1 Create line detection debug panel
    - Design side panel UI for displaying line detection debug information
    - Add real-time coordinate system validation display
    - Show traditional vs unified system comparison data
    - Display phantom line detection warnings and coordinate mismatch alerts
    - _Requirements: 7.1, 7.5, 8.1_

  - [x] 8.2 Add interactive debugging features
    - Implement click-to-inspect functionality for board positions
    - Show coordinate mapping between visual and logical positions
    - Display line detection results for any clicked position
    - Add boundary validation status for each board position
    - _Requirements: 1.4, 4.1, 7.1_

  - [ ] 8.3 Create line detection visualization
    - Highlight detected lines in different colors (traditional vs composite)
    - Show phantom lines and coordinate confusion visually
    - Display continuity validation results for potential lines
    - Add visual indicators for boundary condition failures
    - _Requirements: 3.1, 4.1, 4.2, 7.5_

  - [ ]* 8.4 Add debug logging and export
    - Implement comprehensive debug logging for line detection events
    - Add export functionality for debug sessions
    - Create debug report generation for bug reporting
    - Add performance metrics for line detection operations
    - _Requirements: 8.1, 8.5_

- [x] 9. Investigate scoring calculation accuracy
  - [x] 9.1 Analyze current scoring system implementation
    - Examine composite-scoring.vala and related scoring components
    - Identify all constants, variables, and functions involved in score calculation
    - Map the complete scoring flow from line detection to final score display
    - Document any hardcoded values or magic numbers in scoring logic
    - _Requirements: 2.1, 2.2, 4.3_

  - [x] 9.2 Validate scoring calculation correctness
    - Create test scenarios with known expected scores
    - Compare actual calculated scores against expected values
    - Test scoring accuracy across different line lengths (5, 6, 7+ pieces)
    - Verify scoring consistency across different board sizes
    - Check for any dynamic values or malicious function calls affecting scores
    - _Requirements: 2.1, 2.2, 2.3, 4.3, 4.4_

  - [x] 9.3 Investigate scoring discrepancies
    - Test scoring with various game piece configurations
    - Identify any patterns in incorrect score calculations
    - Check for timing-based or state-dependent scoring issues
    - Verify that removed lines are properly counted in score calculation
    - Examine interaction between traditional and composite scoring systems
    - _Requirements: 2.1, 2.2, 7.1, 7.3_

  - [x] 9.4 Create scoring validation test suite
    - Implement automated tests for score calculation accuracy
    - Create test cases for edge cases and boundary conditions
    - Add regression tests for known scoring issues
    - Test scoring system with phantom line prevention fixes
    - _Requirements: 2.1, 2.2, 4.3, 6.1, 6.5_

- [ ] 10. Integration and validation
  - [ ] 10.1 Integrate all coordinate fixes
    - Ensure all components use consistent coordinate system
    - Validate end-to-end coordinate flow from user input to line detection
    - Test complete game functionality on all board sizes
    - _Requirements: 1.5, 2.5, 3.5, 7.4, 7.5_

  - [x] 10.2 Validate bug fix effectiveness
    - Test specific user-reported scenarios to confirm fixes
    - Verify 4-piece lines are no longer incorrectly removed
    - Confirm phantom lines (endpoint matching) are prevented
    - Test that only truly continuous lines are removed
    - Validate that gaps and foreign pieces properly break line continuity
    - Ensure no more invisible line removal occurs
    - Verify visual feedback matches all piece removals
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 4.1, 4.2, 4.5, 7.1, 7.5_

  - [ ]* 10.3 Performance and stability testing
    - Test game performance with enhanced boundary validation
    - Verify memory usage and error handling improvements
    - Conduct extended gameplay testing on all difficulty levels
    - _Requirements: 4.5, 5.5_