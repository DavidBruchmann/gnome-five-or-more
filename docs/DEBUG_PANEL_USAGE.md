# Five or More - Debug Panel Usage Guide

## Quick Start

### Option 1: Desktop Launcher
- Double-click `five-or-more-debug.desktop`
- Click the **(i) button** in the headerbar to show the info panel

### Option 2: Command Line (Recommended)
```bash
./launch-debug-panel-safe.sh
```
Then click the **(i) button** in the headerbar to show the info panel.

### Option 3: Manual Launch
```bash
cd builddir && ./src/five-or-more
```
Then click the **(i) button** in the headerbar or use Menu > Game Info.

## Debug Panel Controls

| Action | Method |
|--------|--------|
| Toggle Panel | **(i) button** in headerbar or Menu > Game Info |
| Inspect Cell | Click on any board cell |
| Clear Log | Click "Clear Log" button |
| Export Info | Click "Export Info" button |
| Live Updates | Check/uncheck "Enable Live Updates" |

## Debug Panel Sections

### 1. Coordinate System
- Shows game size, difficulty, and board dimensions
- Displays GameDifficulty array values
- Validates coordinate consistency

### 2. Board Dimensions  
- Current board rows and columns
- Grid array dimensions
- Total and filled cell counts
- Dimension mismatch detection

### 3. Selected Position
- Shows currently selected cell coordinates
- Displays piece information (if any)
- Validates position bounds

### 4. Line Detection Comparison
- **Traditional**: Shows classic 5-in-a-row detection results
- **Composite**: Shows new composite line detection results
- Side-by-side comparison of both systems

### 5. Phantom Line Warnings
- Detects lines with fewer than 5 pieces
- Identifies coordinate mismatches
- Shows boundary violations
- Composite line segment information

### 6. Coordinate Validation
- Validates selected position against board bounds
- Checks grid array bounds
- Shows validation status for each coordinate system

### 7. Debug Log
- Timestamped debug messages
- Real-time event logging
- Export functionality for debugging sessions
- Automatic log size management (last 100 messages)

## Usage Tips

1. **Start with Real-time Monitoring ON** - This provides immediate feedback when clicking cells
2. **Click different board positions** - Each click updates all debug information
3. **Compare Traditional vs Composite** - Look for differences in line detection
4. **Watch for Phantom Warnings** - These indicate potential boundary issues
5. **Export debug sessions** - Save debugging information for analysis

## Troubleshooting

### Info Panel Not Visible
- Click the **(i) button** in the headerbar
- Check Menu > Game Info
- Ensure game window is open

### No Debug Information
- Click on board cells to populate information
- Enable "Real-time Monitoring" checkbox
- Check that a game is loaded

### Performance Issues
- Disable "Live Updates" when not actively analyzing
- Clear activity log periodically
- Close info panel when not needed (click (i) button)

## Development Notes

The debug panel is designed to help identify and fix boundary detection issues in the line detection system. It provides comprehensive information about:

- Coordinate system mapping between visual and logical representations
- Traditional vs composite line detection algorithm differences  
- Boundary condition handling and validation
- Real-time system state monitoring

This tool is essential for debugging the line detection boundary fix implementation.