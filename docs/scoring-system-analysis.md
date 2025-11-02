# Five or More Scoring System Analysis

## Overview

The Five or More game implements a dual scoring system with both traditional line scoring and composite line scoring. This analysis documents the complete scoring flow, constants, variables, and functions involved in score calculation.

## Scoring Components

### 1. Traditional Scoring System

**Location:** `src/game.vala` - `update_score()` method

**Formula:**
```vala
score += (int) (SCORE_BASE_MULTIPLIER * Math.log(SCORE_LOG_FACTOR * n_matched));
```

**Constants:**
- `SCORE_BASE_MULTIPLIER`: 45 (default)
- `SCORE_LOG_FACTOR`: 0.25 (default)

**Variables:**
- `n_matched`: Number of pieces in the matched line
- `score`: Current game score (accumulated)

### 2. Composite Scoring System

**Location:** `src/composite-scoring.vala`

#### Base Score Calculation
**Method:** `calculate_base_score(int line_length)`
**Formula:**
```vala
return (int) (45 * Math.log(0.25 * line_length));
```

**Note:** This uses hardcoded values (45, 0.25) instead of the configurable constants from GameConstants.

#### Composite Line Score
**Method:** `calculate_composite_score(CompositeLine composite_line)`
**Formula:**
```vala
base_score + bonus_score
```

#### Bonus Score Calculation
**Location:** `src/composite-line-effects.vala` - `calculate_bonus_score()`
**Formula:**
```vala
base_bonus + complexity_bonus + balance_bonus
```

**Constants:**
- `COMPOSITE_BASE_BONUS`: 25 (default)
- `COMPOSITE_COMPLEXITY_BONUS`: 15 (default)

**Logic:**
- Base bonus: 25 points for multi-segment lines
- Complexity bonus: 15 points × number of segments
- Balance bonus: 25 points if segments differ by ≤1 length, otherwise 10 points

#### Multiple Lines Bonus
**Method:** `calculate_multiple_lines_score()`
**Formula:**
```vala
total_composite_score + (number_of_lines * 50)
```

**Constants:**
- Multiple lines bonus: 50 points per additional line

## Scoring Flow

### Traditional Line Detection Path
1. `Board.get_all_lines_composite()` → `get_all_directions()`
2. If traditional lines found → `Game.update_score(n_matched)`
3. Score calculation: `45 * log(0.25 * n_matched)`

### Composite Line Detection Path
1. `Board.get_all_lines_composite()` → `LineDetector.detect_composite_lines()`
2. If composite lines found → `Game.update_composite_score(composite_lines)`
3. Score calculation: `CompositeScoring.calculate_multiple_lines_score()`

## Constants and Magic Numbers

### Configurable Constants (GameConstants)
- `SCORE_BASE_MULTIPLIER`: 45
- `SCORE_LOG_FACTOR`: 0.25
- `COMPOSITE_BASE_BONUS`: 25
- `COMPOSITE_COMPLEXITY_BONUS`: 15

### Hardcoded Values
- **CRITICAL ISSUE**: `CompositeScoring.calculate_base_score()` uses hardcoded `45` and `0.25` instead of GameConstants
- Multiple lines bonus: 50 points (hardcoded)
- Balance bonus: 25/10 points (hardcoded)

## Identified Issues

### 1. Inconsistent Constant Usage
- Traditional scoring uses configurable constants from GameConstants
- Composite base scoring uses hardcoded values (45, 0.25)
- **Impact**: Configuration changes don't affect composite scoring

### 2. Dual Scoring System Complexity
- Two separate scoring paths with different logic
- Traditional vs composite scoring may produce different results for same line length
- **Impact**: Inconsistent scoring behavior

### 3. Magic Numbers
- Multiple hardcoded values throughout composite scoring
- Balance bonus thresholds (25/10) not configurable
- Multiple lines bonus (50) not configurable

### 4. Score Calculation Discrepancies
- Traditional: `SCORE_BASE_MULTIPLIER * log(SCORE_LOG_FACTOR * n_matched)`
- Composite base: `45 * log(0.25 * line_length)`
- **Impact**: Same line length may score differently depending on detection path

## Score Display Components

### CompositeScoreDisplay
**Location:** `src/composite-score-display.vala`

**Features:**
- Achievement tracking
- Pattern statistics
- Session summaries
- Score breakdown display

**Statistics Tracked:**
- `session_composite_score`: Total composite points in session
- `total_composite_lines`: Number of composite lines cleared
- `pattern_counts`: Frequency of each pattern type
- `best_single_score`: Highest single achievement score
- `recent_achievements`: Last 10 achievements

## Integration Points

### Game.vala Integration
- `update_score()`: Traditional scoring
- `update_composite_score()`: Composite scoring
- Score accumulation in `score` variable
- Signal emission for UI updates

### Window.vala Integration
- Score display updates via `score_display.update_score()`
- Score popover content updates
- Real-time score feedback

## Configuration System

### GameConstants Loading
**Location:** `src/game-constants.vala`

**Configurable Scoring Parameters:**
```ini
[Scoring]
SCORE_BASE_MULTIPLIER=45
SCORE_LOG_FACTOR=0.25
```

**Missing Configuration:**
- Composite bonus values
- Multiple lines bonus
- Balance bonus thresholds

## Recommendations for Investigation

1. **Fix Hardcoded Constants**: Update `CompositeScoring.calculate_base_score()` to use GameConstants
2. **Validate Score Consistency**: Test if traditional and composite base scoring produce identical results
3. **Add Missing Configuration**: Make all scoring parameters configurable
4. **Test Score Accuracy**: Verify calculated scores match expected mathematical results
5. **Investigate Dual System**: Determine if both scoring systems can produce different results for the same scenario