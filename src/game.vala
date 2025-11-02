/*
 * Color lines for GNOME
 * Copyright © 1999 Free Software Foundation
 * Authors: Robert Szokovacs <szo@szo.hu>
 *          Szabolcs Ban <shooby@gnome.hu>
 *          Karuna Grewal <karunagrewal98@gmail.com>
 *          Ruxandra Simion <ruxandra.simion93@gmail.com>
 * Copyright © 2007 Christian Persch
 *
 * This game is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

private class Game : Object
{
    // Use configurable constants
    internal static int N_TYPES { get { return get_game_constants().N_TYPES; } }
    internal static int N_ANIMATIONS { get { return get_game_constants().N_ANIMATIONS; } }
    internal static int N_MATCH { get { return get_game_constants().N_MATCH; } }

    public int size { private get; internal construct set; }
    public int difficulty { private get; internal construct set; } // 0=easy, 1=normal, 2=hard

    internal int get_board_size() {
        return size;
    }
    private NextPiecesGenerator next_pieces_generator;

    internal Board? board = null;
    internal int n_rows {
        internal get {
            assert (board != null);
            return board.n_rows;
        }
    }

    internal int n_cols {
        internal get {
            assert (board != null);
            return board.n_cols;
        }
    }

    internal int n_next_pieces;

    private int n_cells;
    internal int n_filled_cells;

    internal Gee.ArrayList<Cell>? current_path = null;
    internal bool animating = false;
    internal Piece animating_piece;

    internal int score { get; private set; }

    internal signal void current_path_cell_pos_changed ();
    internal signal void line_detection_performed (int row, int col, bool had_lines, int cells_removed);
    private int _current_path_cell_pos = -1;
    internal int current_path_cell_pos
    {
        internal get { return _current_path_cell_pos; }
        internal set
        {
            _current_path_cell_pos = value;
            current_path_cell_pos_changed ();
        }
    }

    internal signal void queue_changed (Gee.ArrayList<Piece> next_pieces_queue);
    internal signal void composite_line_cleared (Gee.ArrayList<CompositeLine> lines, int score, string description);

    private Gee.ArrayList<Piece> _next_pieces_queue;
    internal Gee.ArrayList<Piece> next_pieces_queue
    {
        internal get { return _next_pieces_queue; }
        internal set
        {
            _next_pieces_queue = value;
            queue_changed (_next_pieces_queue);
        }
    }

    internal static GameDifficulty[] game_difficulty {
        get { return get_game_constants().game_difficulty; }
    }

    internal static DifficultyLevel[] difficulty_levels {
        get { return get_game_constants().difficulty_levels; }
    }

    internal const KeyValue scorecats[] = {
        /* Translators: board size, as displayed in the Scores dialog */
        { "Small",  NC_("board size", "Small")  },

        /* Translators: board size, as displayed in the Scores dialog */
        { "Medium", NC_("board size", "Medium") },

        /* Translators: board size, as displayed in the Scores dialog */
        { "Large",  NC_("board size", "Large")  }
    };

    internal bool is_game_over { internal get; private set; default = false; }
    internal signal void game_over ();
    internal int n_categories = 3;
    internal string score_current_category = null;

    internal StatusMessage status_message { get; set; }

    internal Game (int size, int difficulty = 1)
    {
        Object (size: size, difficulty: difficulty);
        init_game ();
    }

    private void init_game ()
    {
        is_game_over = false;
        var n_rows = game_difficulty[size].n_rows;
        var n_cols = game_difficulty[size].n_cols;

        // Use difficulty level to determine pieces per round
        this.n_next_pieces = difficulty_levels[difficulty].pieces_per_round[size];
        // this.n_next_pieces = game_difficulty[size].n_next_pieces;

        this.n_cells = n_rows * n_cols;
        this.n_filled_cells = 0;

        this.score = 0;
        this.score_current_category = scorecats[size - 1].key;

        this.status_message = DESCRIPTION;

        this.next_pieces_generator = new NextPiecesGenerator (this.n_next_pieces,
                                                         game_difficulty[size].n_types);
        generate_next_pieces ();

        if (board == null)
            board = new Board (n_rows, n_cols);
        else
            board.reset (n_rows, n_cols);

        fill_board (n_rows, n_cols);

        generate_next_pieces ();
    }

    internal void generate_next_pieces ()
    {
        this.next_pieces_queue = this.next_pieces_generator.yield_next_pieces ();
    }

    private void fill_board (int n_rows, int n_cols)
    {
        int row = -1, col = -1;

        for (int i = 0; i < next_pieces_queue.size; i++)
        {
            do
            {
                row = GLib.Random.int_range (0, n_rows);
                col = GLib.Random.int_range (0, n_cols);
            } while (board.get_piece (row, col) != null);

            board.set_piece (row, col, next_pieces_queue [i]);

            var line_result = board.get_cell (row, col).get_all_lines_composite (board.get_grid ());
            if (line_result.has_any_lines())
            {
                var cells_to_remove = line_result.get_cells_to_remove();
                n_filled_cells -= cells_to_remove.size;

                // Emit line detection signal for debugging
                line_detection_performed (row, col, true, cells_to_remove.size);

                foreach (Cell cell in cells_to_remove)
                {
                    board.set_piece (cell.row, cell.col, null);
                }

                if (line_result.has_composite_lines) {
                    update_composite_score (line_result.composite_lines);
                } else {
                    update_score (cells_to_remove.size);
                }
            }

            board.grid_changed ();
            n_filled_cells ++;

            if (check_game_over ())
            {
                status_message = GAME_OVER;
                board.grid_changed ();
                return;
            }
        }
    }

    private void update_score (int n_matched)
    {
        var constants = get_game_constants();
        score += (int) (constants.SCORE_BASE_MULTIPLIER * Math.log (constants.SCORE_LOG_FACTOR * n_matched));
    }

    private void update_composite_score (Gee.ArrayList<CompositeLine> composite_lines)
    {
        int composite_score = CompositeScoring.calculate_multiple_lines_score (composite_lines);
        string description = CompositeScoring.get_multiple_lines_description (composite_lines, composite_score);

        score += composite_score;
        composite_line_cleared (composite_lines, composite_score, description);
    }

    private bool check_game_over ()
    {
        if (n_cells - n_filled_cells == 0)
        {
            is_game_over = true;
            game_over ();
            return true;
        }

        return false;
    }

    internal void next_step ()
    {
        fill_board (this.n_rows, this.n_cols);
        generate_next_pieces ();
    }

    internal bool make_move (int start_row, int start_col, int end_row, int end_col)
    {
        current_path = board.find_path (start_row,
                                        start_col,
                                        end_row,
                                        end_col);

        if (current_path == null || current_path.size == 0)
        {
            status_message = NO_PATH;
            return false;
        }

        current_path_cell_pos = 0;
        animating_piece = current_path.get (current_path_cell_pos).piece;
        Timeout.add (get_game_constants().ANIMATION_STEP_MS, animate);

        return true;
    }

    internal bool animate ()
    {
        animating = true;

        Cell curr_cell = current_path[current_path_cell_pos];

        if (current_path_cell_pos == 0)
            board.set_piece (curr_cell.row, curr_cell.col, null);

        if (current_path_cell_pos == current_path.size - 1)
        {
            board.set_piece (curr_cell.row, curr_cell.col, animating_piece);

            current_path = null;
            var line_result = curr_cell.get_all_lines_composite (board.get_grid ());

            if (line_result.has_any_lines())
            {
                var cells_to_remove = line_result.get_cells_to_remove();
                n_filled_cells -= cells_to_remove.size;

                // Emit line detection signal for debugging
                line_detection_performed (curr_cell.row, curr_cell.col, true, cells_to_remove.size);

                foreach (Cell cell in cells_to_remove)
                {
                    board.set_piece (cell.row, cell.col, null);
                }

                if (line_result.has_composite_lines) {
                    update_composite_score (line_result.composite_lines);
                } else {
                    update_score (cells_to_remove.size);
                }
            }

            if (!line_result.has_any_lines())
                next_step ();

            board.grid_changed ();
            animating = false;

            return Source.REMOVE;
        }

        current_path_cell_pos++;

        return Source.CONTINUE;
    }

    internal void new_game (int _size, int _difficulty = -1)
    {
        size = _size;
        if (_difficulty >= 0)
            difficulty = _difficulty;
        init_game ();
    }

    internal void change_difficulty (int _difficulty)
    {
        difficulty = _difficulty;
        init_game ();
    }

    internal string get_difficulty_name ()
    {
        switch (difficulty_levels[difficulty].key) {
            case "easy":   return _("Easy");
            case "normal": return _("Normal");
            case "hard":   return _("Hard");
            default:       return _("Normal");
        }
    }

    internal int get_pieces_per_round ()
    {
        return difficulty_levels[difficulty].pieces_per_round[size];
    }
}

private struct GameDifficulty
{
    public int n_cols;
    public int n_rows;
    public int n_types;
    public int n_next_pieces;
}

private struct DifficultyLevel
{
    public string key;
    public string name;
    public int[] pieces_per_round;
}

private struct KeyValue
{
    public string key;
    public string name;
}

private enum StatusMessage
{
    DESCRIPTION,
    NO_PATH,
    GAME_OVER,
    NONE,
}
