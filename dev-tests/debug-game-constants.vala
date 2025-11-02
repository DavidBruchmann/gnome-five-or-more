/*
 * Debug game constants to see actual values
 */

using Gee;

// Mock structures for testing
private struct GameDifficulty {
    public int n_cols;
    public int n_rows;
    public int n_types;
    public int n_next_pieces;
}

private struct DifficultyLevel {
    public string key;
    public string name;
    public int pieces_per_round;
}

// Mock game constants
internal class GameConstants : Object {
    private static GameConstants? _instance = null;
    internal static GameConstants instance {
        get {
            if (_instance == null) {
                _instance = new GameConstants();
            }
            return _instance;
        }
    }
    
    internal GameDifficulty[] game_difficulty { get; private set; }
    internal int N_MATCH { get; private set; default = 5; }
    
    construct {
        game_difficulty = {
            { -1, -1, -1, -1 },  // Invalid/placeholder
            {  7,  7,  5,  3 },  // Small
            {  9,  9,  7,  3 },  // Medium  
            { 20, 15,  7,  7 }   // Large
        };
    }
}

internal GameConstants get_game_constants() {
    return GameConstants.instance;
}

// Mock Game class
internal class Game : Object {
    internal static int N_MATCH { get { return get_game_constants().N_MATCH; } }
}

int main(string[] args) {
    print("Debugging Game Constants\n");
    print("=======================\n\n");
    
    var constants = get_game_constants();
    
    print("N_MATCH value: %d\n", Game.N_MATCH);
    print("Expected: 5 pieces required for a line\n\n");
    
    if (Game.N_MATCH != 5) {
        print("❌ PROBLEM FOUND: N_MATCH is not 5!\n");
        print("This could explain why lines are being removed with fewer pieces.\n");
    } else {
        print("✅ N_MATCH is correct (5 pieces required)\n");
        print("The problem is likely in the line detection logic itself.\n");
    }
    
    print("\nBoard sizes:\n");
    for (int i = 1; i < constants.game_difficulty.length; i++) {
        var diff = constants.game_difficulty[i];
        print("Size %d: %dx%d board\n", i, diff.n_cols, diff.n_rows);
    }
    
    return 0;
}