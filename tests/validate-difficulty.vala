/*
 * Five or More - Difficulty System Validation
 * Copyright © 2024 Five or More Contributors
 *
 * Simple validation script to test difficulty functionality
 */

public class DifficultyValidation : Object {
    
    public static int main(string[] args) {
        print("Testing Difficulty system...\n");
        
        // Test 1: Create games with different difficulties
        print("1. Creating games with different difficulties...\n");
        var easy_game = new Game(2, 0);    // Medium board, Easy difficulty
        var normal_game = new Game(2, 1);  // Medium board, Normal difficulty  
        var hard_game = new Game(2, 2);    // Medium board, Hard difficulty
        
        assert(easy_game.get_pieces_per_round() == 2);
        assert(normal_game.get_pieces_per_round() == 3);
        assert(hard_game.get_pieces_per_round() == 4);
        print("   ✓ Difficulty levels set correctly\n");
        
        // Test 2: Test difficulty names
        print("2. Testing difficulty names...\n");
        assert(easy_game.get_difficulty_name() == "Easy");
        assert(normal_game.get_difficulty_name() == "Normal");
        assert(hard_game.get_difficulty_name() == "Hard");
        print("   ✓ Difficulty names correct\n");
        
        // Test 3: Test difficulty change
        print("3. Testing difficulty change...\n");
        var test_game = new Game(2, 1); // Start with normal
        assert(test_game.get_pieces_per_round() == 3);
        
        test_game.change_difficulty(0); // Change to easy
        assert(test_game.get_pieces_per_round() == 2);
        
        test_game.change_difficulty(2); // Change to hard
        assert(test_game.get_pieces_per_round() == 4);
        print("   ✓ Difficulty change successful\n");
        
        // Test 4: Test new game with difficulty
        print("4. Testing new game with difficulty...\n");
        var game = new Game(1, 0); // Small board, easy
        assert(game.get_pieces_per_round() == 2);
        
        game.new_game(2, 2); // Change to medium board, hard difficulty
        assert(game.get_pieces_per_round() == 4);
        print("   ✓ New game with difficulty successful\n");
        
        print("\n✅ All difficulty tests passed!\n");
        print("Difficulty system is working correctly:\n");
        print("  - Easy: 2 pieces per round\n");
        print("  - Normal: 3 pieces per round\n");
        print("  - Hard: 4 pieces per round\n");
        
        return 0;
    }
}