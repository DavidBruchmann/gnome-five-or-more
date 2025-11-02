/*
 * Comprehensive debug tool to trace phantom line bug in real game
 */

void main() {
    print("=== Comprehensive Phantom Line Debug Tool ===\n");
    print("\nThis tool will help debug the phantom line bug by:\n");
    print("1. Adding debug output to the actual game\n");
    print("2. Tracing line detection calls\n");
    print("3. Logging grid state before/after line detection\n");
    print("4. Identifying the exact cause of phantom line removal\n");
    print("\nTo use this tool:\n");
    print("1. Compile the game with debug output\n");
    print("2. Run the game and reproduce the bug\n");
    print("3. Check the debug output to see what's happening\n");
    print("\nDEBUG INSTRUCTIONS:\n");
    print("==================\n");
    print("Add these debug lines to src/game.vala around line 274:\n");
    print("\n");
    print("// DEBUG: Before line detection\n");
    print("print(\"DEBUG: Checking lines at (%%d, %%d)\\n\", curr_cell.row, curr_cell.col);\n");
    print("print(\"DEBUG: Grid state before line detection:\\n\");\n");
    print("for (int r = 0; r < board.n_rows; r++) {\n");
    print("    for (int c = 0; c < board.n_cols; c++) {\n");
    print("        var cell = board.get_cell(r, c);\n");
    print("        if (cell.piece != null) {\n");
    print("            print(\"(%%d,%%d)=%%d \", r, c, cell.piece.id);\n");
    print("        }\n");
    print("    }\n");
    print("}\n");
    print("print(\"\\n\");\n");
    print("\n");
    print("var line_result = curr_cell.get_all_lines_composite (board.get_grid ());\n");
    print("\n");
    print("// DEBUG: After line detection\n");
    print("if (line_result.has_any_lines()) {\n");
    print("    print(\"DEBUG: Lines detected! Type: %%s\\n\", \n");
    print("          line_result.has_traditional_lines ? \"traditional\" : \"composite\");\n");
    print("    var cells_to_remove = line_result.get_cells_to_remove();\n");
    print("    print(\"DEBUG: Cells to remove (%%d total):\\n\", cells_to_remove.size);\n");
    print("    foreach (Cell cell in cells_to_remove) {\n");
    print("        print(\"  (%%d,%%d) piece=%%d\\n\", cell.row, cell.col, \n");
    print("              cell.piece != null ? cell.piece.id : -1);\n");
    print("    }\n");
    print("} else {\n");
    print("    print(\"DEBUG: No lines detected\\n\");\n");
    print("}\n");
    print("\n");
    print("MANUAL TESTING STEPS:\n");
    print("====================\n");
    print("1. Add the debug code above to src/game.vala\n");
    print("2. Recompile: meson compile -C builddir\n");
    print("3. Run: ./builddir/src/five-or-more\n");
    print("4. Set up your phantom line pattern: XXX-Y-XXX\n");
    print("5. Move a piece to trigger line detection\n");
    print("6. Check the debug output to see:\n");
    print("   - What the grid state looks like\n");
    print("   - Which cells are being marked for removal\n");
    print("   - Whether it's traditional or composite line detection\n");
    print("   - The exact coordinates of the phantom line\n");
    print("\n");
    print("This will help us identify if:\n");
    print("- The grid state is corrupted\n");
    print("- The line detection is being called with wrong coordinates\n");
    print("- There's a race condition or timing issue\n");
    print("- The bug is in a specific direction (horizontal/vertical/diagonal)\n");
    print("\n");
    print("Please run this debug version and report the output!\n");
}