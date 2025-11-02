/*
 * Test to understand the correct line detection rules
 */

int main(string[] args) {
    print("Testing Line Detection Rules\n");
    print("===========================\n\n");
    
    print("According to user clarification:\n");
    print("- A line is valid if there are 5+ matching pieces in a row/column/diagonal\n");
    print("- Gaps are allowed - e.g., 3 pieces + gap + 2 pieces = 5 total = valid line\n");
    print("- Only the total count matters, not strict continuity\n\n");
    
    print("Current implementation analysis:\n");
    print("- get_direction() stops at first empty cell or different piece\n");
    print("- This means it only finds continuous sequences\n");
    print("- This is TOO RESTRICTIVE according to the rules\n\n");
    
    print("Example scenarios:\n");
    print("1. [Red][Red][Red][Empty][Red][Red] = 5 Red pieces = SHOULD be valid\n");
    print("   Current code: Finds 3 left + 2 right = stops at empty = INVALID\n");
    print("   Correct behavior: Count all 5 Red pieces = VALID\n\n");
    
    print("2. [Red][Red][Blue][Red][Red][Red] = 5 Red pieces = SHOULD be valid\n");
    print("   Current code: Finds 2 left + 3 right = stops at Blue = INVALID\n");
    print("   Correct behavior: Count all 5 Red pieces = VALID\n\n");
    
    print("3. [Red][Red][Red][Red] = 4 Red pieces = SHOULD be invalid\n");
    print("   Current code: Finds 4 continuous = INVALID (correct)\n");
    print("   Correct behavior: Count 4 Red pieces = INVALID (correct)\n\n");
    
    print("The bug is that line detection requires strict continuity\n");
    print("when it should count ALL matching pieces in a direction!\n");
    
    return 0;
}