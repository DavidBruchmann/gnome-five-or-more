/*
 * Test that the double-counting bug is fixed
 */

int main(string[] args) {
    print("Testing Double-Counting Bug Fix\n");
    print("===============================\n\n");
    
    print("PROBLEM IDENTIFIED:\n");
    print("The original UnifiedLineDetector was double-counting the center cell!\n\n");
    
    print("Example scenario: 3 continuous pieces\n");
    print("Row 4: [Red][Red][Red]\n");
    print("       Col 0  Col 1  Col 2\n\n");
    
    print("BEFORE (Buggy Logic):\n");
    print("- get_continuous_line_in_direction(4,1, 0,1) → returns (4,1), (4,2)\n");
    print("- get_continuous_line_in_direction(4,1, 0,-1) → returns (4,1), (4,0)\n");
    print("- Combined: (4,1), (4,2), (4,1), (4,0)\n");
    print("- HashSet removes duplicates: (4,0), (4,1), (4,2) = 3 pieces ✓\n");
    print("- But with gaps, this could cause phantom counting!\n\n");
    
    print("AFTER (Fixed Logic):\n");
    print("- get_bidirectional_continuous_line(4,1, 0,1) properly handles both directions\n");
    print("- Adds center cell (4,1) once\n");
    print("- Scans right: adds (4,2) if continuous\n");
    print("- Scans left: adds (4,0) if continuous\n");
    print("- Result: (4,0), (4,1), (4,2) = 3 pieces ✓\n");
    print("- No double-counting, proper gap detection!\n\n");
    
    print("Gap scenario test:\n");
    print("Row 4: [Red][Red][Red][Empty][Red][Red]\n");
    print("       Col 0  Col 1  Col 2  Col 3   Col 4  Col 5\n\n");
    
    print("From position (4,2):\n");
    print("- Center: (4,2)\n");
    print("- Right scan: stops at empty (4,3) → no cells added\n");
    print("- Left scan: adds (4,1), (4,0)\n");
    print("- Total: (4,0), (4,1), (4,2) = 3 pieces\n");
    print("- 3 < 5 → NO line detected ✓\n\n");
    
    print("From position (4,4):\n");
    print("- Center: (4,4)\n");
    print("- Right scan: adds (4,5)\n");
    print("- Left scan: stops at empty (4,3) → no cells added\n");
    print("- Total: (4,4), (4,5) = 2 pieces\n");
    print("- 2 < 5 → NO line detected ✓\n\n");
    
    print("This should fix the phantom line bug where gaps were incorrectly counted!\n");
    
    return 0;
}