# Scoring Discrepancies Investigation Report

## Executive Summary

The investigation revealed several critical issues in the Five or More scoring system that could lead to inconsistent behavior and configuration problems.

## Key Findings

### 1. **CRITICAL**: Hardcoded Constants in Composite Scoring

**Issue**: The `CompositeScoring.calculate_base_score()` method uses hardcoded values (45, 0.25) instead of the configurable GameConstants.

**Impact**: 
- Configuration changes to `SCORE_BASE_MULTIPLIER` and `SCORE_LOG_FACTOR` only affect traditional scoring
- Composite scoring remains fixed regardless of user configuration
- This creates inconsistency when users modify scoring parameters

**Evidence**: 
```vala
// Traditional scoring (configurable)
score += (int) (constants.SCORE_BASE_MULTIPLIER * Math.log (constants.SCORE_LOG_FACTOR * n_matched));

// Composite scoring (hardcoded)
return (int) (45 * Math.log(0.25 * line_length));
```

### 2. Dual Scoring System Complexity

**Issue**: The game uses two separate scoring paths with different logic complexity.

**Behavior**:
- Traditional lines: Base score only
- Composite lines: Base score + bonus calculations + multiple line bonuses

**Impact**: Same line length can produce vastly different scores depending on detection method.

**Example**:
- Simple 5-piece line (traditional): 10 points
- Complex 2-segment pattern (composite): 90 points (10 base + 80 bonus)

### 3. Configuration System Gaps

**Missing Configurable Parameters**:
- `COMPOSITE_BASE_BONUS` (hardcoded: 25)
- `COMPOSITE_COMPLEXITY_BONUS` (hardcoded: 15)
- Multiple lines bonus (hardcoded: 50 per line)
- Balance bonus thresholds (hardcoded: 25/10)

### 4. Score Calculation Accuracy

**Positive Findings**:
- ✅ Base mathematical formulas are correct
- ✅ Floating point precision is handled properly
- ✅ Scoring is independent of game state and timing
- ✅ Traditional and composite base scoring produce identical results when using same constants

**Validation Results**:
- All line lengths (5-10 pieces) calculated correctly
- Score progression increases properly with line length
- Board size does not affect scoring (as expected)
- Edge cases handled appropriately

## Detailed Test Results

### Mathematical Accuracy
```
5-piece line: 10 points ✓
6-piece line: 18 points ✓
7-piece line: 25 points ✓
8-piece line: 31 points ✓
9-piece line: 36 points ✓
10-piece line: 41 points ✓
```

### System Consistency
- Traditional vs Composite base scoring: **100% consistent** when using same constants
- Configuration impact: **Only affects traditional scoring**
- Timing independence: **Confirmed**
- State independence: **Confirmed**

### Composite Bonus Calculations
```
Single segment: 0 bonus ✓
Two balanced segments (5+5): 80 bonus
Two unbalanced segments (5+7): 65 bonus  
Three balanced segments (5+5+5): 95 bonus
Multiple lines bonus: 50 points per additional line ✓
```

## Risk Assessment

### High Risk Issues
1. **Configuration Inconsistency**: Users cannot properly configure composite scoring
2. **Code Maintenance**: Hardcoded values scattered throughout codebase
3. **Future Modifications**: Changes to scoring constants won't affect composite system

### Medium Risk Issues
1. **Player Confusion**: Dramatic score differences between traditional and composite lines
2. **Balance Issues**: Composite patterns may be overpowered compared to traditional lines

### Low Risk Issues
1. **Performance**: Dual system adds complexity but no significant performance impact
2. **Compatibility**: Current behavior is consistent within each system

## Recommendations

### Immediate Fixes (High Priority)
1. **Fix Hardcoded Constants**: Update `CompositeScoring.calculate_base_score()` to use GameConstants
2. **Add Missing Configuration**: Make all composite scoring parameters configurable
3. **Validate Configuration Loading**: Ensure all scoring parameters are properly loaded from config

### Medium Priority Improvements
1. **Unified Configuration**: Create single scoring configuration section
2. **Documentation**: Document scoring behavior differences between systems
3. **Testing**: Add automated tests for configuration consistency

### Long-term Considerations
1. **System Unification**: Consider merging traditional and composite scoring into unified system
2. **Balance Review**: Evaluate if composite bonuses are appropriately balanced
3. **User Interface**: Provide clear feedback about which scoring system is active

## Test Coverage

### Completed Tests
- ✅ Basic mathematical accuracy (all line lengths)
- ✅ System consistency validation
- ✅ Edge case handling
- ✅ Configuration impact analysis
- ✅ Timing and state independence
- ✅ Composite bonus calculations
- ✅ Multiple lines bonus validation

### Recommended Additional Tests
- Configuration file loading and validation
- Integration tests with actual game components
- Performance benchmarks for scoring calculations
- User acceptance testing for scoring balance

## Conclusion

The scoring system is mathematically sound but suffers from configuration inconsistencies due to hardcoded values in the composite scoring system. The immediate priority should be fixing the hardcoded constants to ensure configuration changes affect both scoring systems consistently.