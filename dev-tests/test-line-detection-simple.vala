/*
 * Simple test to check line detection constants
 */

void test_line_detection() {
    print("Line Detection Analysis\n");
    print("======================\n");
    
    print("Default constants that should be used:\n");
    print("- N_MATCH: 5 pieces (traditional Five or More)\n");
    print("- N_TYPES: 7 different piece types\n");
    print("- Board sizes: Small(7x7), Medium(9x9), Large(20x15)\n");
    
    print("\nPotential issues to investigate:\n");
    print("1. Coordinate system confusion (row,col vs x,y)\n");
    print("2. Off-by-one errors in boundary checking\n");
    print("3. Inconsistent use of N_MATCH constant\n");
    print("4. Board dimension mismatches\n");
    
    print("\nKey areas to check:\n");
    print("- board.vala: get_neighbour() boundary logic\n");
    print("- board.vala: get_direction() line scanning\n");
    print("- line-detector.vala: composite line detection\n");
    print("- game.vala: N_MATCH constant usage\n");
    
    print("\nRun the game and test:\n");
    print("cd builddir && ./src/five-or-more\n");
    print("Enable debug panel and click on board positions\n");
    print("Check if 5-piece lines are detected correctly\n");
}

int main() {
    test_line_detection();
    return 0;
}