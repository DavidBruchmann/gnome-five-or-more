/*
 * Simple test to isolate the phantom line bug
 */

void main() {
    print("=== Simple Phantom Line Bug Test ===\n");
    
    // Compile and run the game to test the actual behavior
    test_game_behavior();
}

void test_game_behavior() {
    print("Testing phantom line bug with actual game...\n");
    
    // Run the game with debug output
    print("Starting Five or More game...\n");
    print("Please set up the pattern: 2 pieces - gap - 1 piece - gap - 2 pieces\n");
    print("Then check if phantom lines are detected.\n");
    
    // The user should manually test this pattern in the actual game
    print("\nTo test:\n");
    print("1. Start the game: ./run-five-or-more.sh\n");
    print("2. Place pieces in pattern: XX-X-XX (where X = same color, - = gap)\n");
    print("3. Check if the game incorrectly removes these pieces\n");
    print("4. If it does, the phantom line bug is still present\n");
}