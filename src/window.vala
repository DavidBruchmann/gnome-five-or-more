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

using Gtk;

[GtkTemplate (ui = "/org/gnome/five-or-more/ui/five-or-more.ui")]
private class GameWindow : ApplicationWindow
{
    [GtkChild]
    internal unowned HeaderBar headerbar;

    [GtkChild]
    private unowned Box preview_hbox;

    [GtkChild]
    private unowned Games.GridFrame grid_frame;

    [GtkChild]
    private unowned Button info_panel_button;

    private GLib.Settings settings = new GLib.Settings ("org.gnome.five-or-more");
    private bool window_tiled;
    private bool window_maximized;
    private int window_width;
    private int window_height;

    private Game? game = null;
    private ThemeRenderer? theme = null;
    private CompositeScoreDisplay? score_display = null;
    private Gtk.Popover? score_popover = null;
    private Gtk.Button? score_button = null;
    private TabbedSidebar? sidebar_panel = null;
    private bool sidebar_visible = false;
    private ComboModeIndicatorManager? indicator_manager = null;

    private string[] status = {
        /* Translators: subtitle of the headerbar, at the application start */
        _("Match five objects of the same type in a row to score!"),

        /* Translators: subtitle of the headerbar, when the user clicked on a tile where the selected marble cannot move */
        _("You can’t move there!"),

        /* Translators: subtitle of the headerbar, at the end of a game */
        _("Game Over!"),

        /* Translators: subtitle of the headerbar, during a game; the %d is replaced by the score */
        _("Score: %d")
    };

    private const GLib.ActionEntry win_actions [] =
    {
        { "background",     change_background  },
        { "reset-bg",       reset_background   },

        { "change-size",      null,   "s", "'small'",     change_size       },
        { "change-theme",     null,   "s", "'balls.svg'", change_theme      },
        { "change-difficulty", null,   "s", "'normal'",    change_difficulty },

        { "new-game",       new_game           },
        { "scores",         show_scores        },
        { "toggle-combo-mode", toggle_combo_mode },
        { "toggle-info",    toggle_info_panel  }
    };

    construct
    {
        add_action_entries (win_actions, this);

        SimpleAction theme_action = (SimpleAction) lookup_action ("change-theme");
        string theme_value = settings.get_string (FiveOrMoreApp.KEY_THEME);
        if (theme_value != "balls.svg" && theme_value != "shapes.svg" && theme_value != "tango.svg") /* TODO use an enum in GSchema file? */
        {
            settings.set_string (FiveOrMoreApp.KEY_THEME, "balls.svg");
            theme_value = "balls.svg";
        }
        theme_action.set_state (new Variant.@string (theme_value));

        var board_size_action = lookup_action ("change-size");
        string board_size_string;
        int board_size = settings.get_int (FiveOrMoreApp.KEY_SIZE);
        switch (board_size)
        {
            case 1: board_size_string = "small";    break;
            case 2: board_size_string = "medium";   break;
            case 3: board_size_string = "large";    break;
            default: assert_not_reached ();
        }
        ((SimpleAction) board_size_action).set_state (board_size_string);

        // Initialize difficulty action
        SimpleAction difficulty_action = (SimpleAction) lookup_action ("change-difficulty");
        string difficulty_value = settings.get_string (FiveOrMoreApp.KEY_DIFFICULTY);
        if (difficulty_value != "easy" && difficulty_value != "normal" && difficulty_value != "hard")
        {
            settings.set_string (FiveOrMoreApp.KEY_DIFFICULTY, "normal");
            difficulty_value = "normal";
        }
        difficulty_action.set_state (new Variant.@string (difficulty_value));

        // Get difficulty setting
        int difficulty_level = 1; // default to normal
        string difficulty_string = settings.get_string (FiveOrMoreApp.KEY_DIFFICULTY);
        switch (difficulty_string)
        {
            case "easy":   difficulty_level = 0; break;
            case "normal": difficulty_level = 1; break;
            case "hard":   difficulty_level = 2; break;
            default: difficulty_level = 1; break;
        }

        game = new Game (board_size, difficulty_level);
        theme = new ThemeRenderer (settings);
        score_display = new CompositeScoreDisplay ();

        // Initialize composite lines setting (defaults to false for traditional mode)
        var constants = get_game_constants();
        constants.ENABLE_COMPOSITE_LINES = false;

        setup_score_display ();

        set_default_size (settings.get_int ("window-width"), settings.get_int ("window-height"));
        if (settings.get_boolean ("window-is-maximized"))
            maximize ();

        NextPiecesWidget next_pieces_widget = new NextPiecesWidget (settings, game, theme);
        preview_hbox.pack_start (next_pieces_widget);
        next_pieces_widget.realize ();
        next_pieces_widget.show ();

        grid_frame.set (game.n_cols, game.n_rows);
        game.board.board_changed.connect (() => { grid_frame.set (game.n_cols, game.n_rows); });
        game.notify["score"].connect ((s, p) => {
            set_status_message (status[StatusMessage.NONE].printf(game.score));
            score_display.update_score(game.score);
            if (score_button != null) {
                score_button.set_label (@"Score: $(game.score)");
            }
        });
        game.notify["status-message"].connect ((s, p) => { set_status_message (status[game.status_message].printf(game.score)); });
        game.composite_line_cleared.connect (on_composite_line_cleared);
        set_status_message (status[game.status_message]);

        View game_view = new View (game, theme);
        SimpleAction reset_background_action = (SimpleAction) lookup_action ("reset-bg");
        game_view.notify ["background-color"].connect (() => { reset_background_action.set_enabled (game_view.background_color != View.default_background_color); });
        settings.bind (FiveOrMoreApp.KEY_BACKGROUND_COLOR, game_view, "background-color", SettingsBindFlags.DEFAULT);

        // Connect sidebar panel to view clicks with enhanced coordinate validation
        game_view.cell_clicked_debug.connect ((row, col) => {
            if (sidebar_panel != null) {
                sidebar_panel.on_board_clicked (row, col);

                // Validate coordinate mapping for debugging
                // Note: In the view, cell_clicked_debug emits (row, col) which are logical coordinates
                // The visual click coordinates were (col, row) in the original click
                sidebar_panel.validate_coordinate_mapping (col, row, row, col);
            }
        });

        grid_frame.add (game_view);
        game_view.show ();

        grid_frame.show ();

        setup_sidebar_panel ();
        init_scores_dialog ();

        // Initialize combo mode indicator manager
        setup_combo_mode_indicators ();

        // Add a periodic check to ensure window integrity
        Timeout.add_seconds (1, () => {
            ensure_window_has_content ();
            return Source.CONTINUE;
        });
    }

    protected override bool window_state_event (Gdk.EventWindowState event)
    {
        base.window_state_event (event);

        if ((event.changed_mask & Gdk.WindowState.MAXIMIZED) != 0)
            window_maximized = (event.new_window_state & Gdk.WindowState.MAXIMIZED) != 0;

        if ((event.changed_mask & Gdk.WindowState.TILED) != 0)
            window_tiled = (event.new_window_state & Gdk.WindowState.TILED) != 0;

        return false;
    }

    protected override void size_allocate (Allocation allocation)
    {
        base.size_allocate (allocation);

        if (window_maximized || window_tiled)
            return;

        window_width = allocation.width;
        window_height = allocation.height;
    }

    internal inline void on_shutdown ()
    {
        // Cleanup indicator manager
        if (indicator_manager != null) {
            indicator_manager.cleanup ();
        }

        settings.delay ();
        settings.set_int ("window-width", window_width);
        settings.set_int ("window-height", window_height);
        settings.set_boolean ("window-is-maximized", window_maximized);
        settings.apply ();
    }

    private void set_status_message (string? message)
    {
        headerbar.set_subtitle (message);
    }

    private void on_composite_line_cleared (Gee.ArrayList<CompositeLine> lines, int score, string description)
    {
        score_display.show_composite_achievement (lines, score, description);

        // Update headerbar with achievement notification
        string achievement_message;
        if (lines.size == 1) {
            achievement_message = @"$(lines[0].get_pattern_description()) - +$(score) points!";
        } else {
            achievement_message = @"$(lines.size) lines cleared - +$(score) points!";
        }

        // Temporarily show achievement, then revert to normal score display
        headerbar.set_subtitle (achievement_message);
        Timeout.add (3000, () => {
            set_status_message (status[StatusMessage.NONE].printf(game.score));
            return Source.REMOVE;
        });
    }

    private void setup_score_display ()
    {
        // Create score button for headerbar
        score_button = new Gtk.Button.with_label ("Score: 0");
        score_button.get_style_context ().add_class ("flat");
        score_button.clicked.connect (() => {
            if (score_popover == null) {
                create_score_popover ();
            }
            update_score_popover_content ();
            score_popover.show ();
        });

        headerbar.pack_end (score_button);
        score_button.show ();

        // Connect to score display signals
        score_display.achievement_recorded.connect (on_achievement_recorded);
    }

    private void create_score_popover ()
    {
        score_popover = new Gtk.Popover (score_button);
        score_popover.set_position (Gtk.PositionType.BOTTOM);

        var popover_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        popover_box.margin = 12;
        popover_box.set_size_request (300, -1);

        score_popover.add (popover_box);
        popover_box.show ();
    }

    private void update_score_popover_content ()
    {
        if (score_popover == null) return;

        var popover_box = (Gtk.Box) score_popover.get_child ();

        // Clear existing content
        popover_box.foreach ((child) => {
            popover_box.remove (child);
        });

        // Add score breakdown
        var breakdown_label = new Gtk.Label (score_display.get_score_breakdown ());
        breakdown_label.set_line_wrap (true);
        breakdown_label.set_xalign (0);
        popover_box.pack_start (breakdown_label, false, false, 0);
        breakdown_label.show ();

        // Add separator
        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        popover_box.pack_start (separator, false, false, 6);
        separator.show ();

        // Add recent achievements
        var achievements_label = new Gtk.Label ("Recent Achievements:");
        achievements_label.set_markup ("<b>Recent Achievements:</b>");
        achievements_label.set_xalign (0);
        popover_box.pack_start (achievements_label, false, false, 0);
        achievements_label.show ();

        var recent_achievements = score_display.get_recent_achievements ();
        if (recent_achievements.size == 0) {
            var no_achievements_label = new Gtk.Label ("No composite lines achieved yet.");
            no_achievements_label.set_xalign (0);
            no_achievements_label.get_style_context ().add_class ("dim-label");
            popover_box.pack_start (no_achievements_label, false, false, 0);
            no_achievements_label.show ();
        } else {
            for (int i = recent_achievements.size - 1; i >= 0 && i >= recent_achievements.size - 5; i--) {
                var achievement = recent_achievements[i];
                var achievement_label = new Gtk.Label (score_display.get_achievement_notification (achievement));
                achievement_label.set_xalign (0);
                achievement_label.set_line_wrap (true);

                if (score_display.is_notable_achievement (achievement)) {
                    achievement_label.get_style_context ().add_class ("accent");
                }

                popover_box.pack_start (achievement_label, false, false, 0);
                achievement_label.show ();
            }
        }

        // Add pattern statistics
        var stats_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        popover_box.pack_start (stats_separator, false, false, 6);
        stats_separator.show ();

        var stats_label = new Gtk.Label (score_display.get_pattern_statistics ());
        stats_label.set_line_wrap (true);
        stats_label.set_xalign (0);
        popover_box.pack_start (stats_label, false, false, 0);
        stats_label.show ();
    }

    private void on_achievement_recorded (CompositeAchievement achievement)
    {
        // Update score button text
        if (score_button != null) {
            score_button.set_label (@"Score: $(score_display.current_score)");
        }

        // Show notification for notable achievements
        if (score_display.is_notable_achievement (achievement)) {
            show_achievement_notification (achievement);
        }
    }

    private void show_achievement_notification (CompositeAchievement achievement)
    {
        // Create a proper modal dialog instead of manipulating the main container
        var dialog = new Gtk.MessageDialog (this,
                                          Gtk.DialogFlags.MODAL,
                                          Gtk.MessageType.INFO,
                                          Gtk.ButtonsType.OK,
                                          "Achievement Unlocked!");

        dialog.secondary_text = score_display.get_achievement_notification (achievement);
        dialog.set_title ("Five or More - Achievement");

        // Auto-close after 3 seconds
        Timeout.add (3000, () => {
            if (dialog.visible) {
                dialog.response (Gtk.ResponseType.OK);
            }
            return Source.REMOVE;
        });

        // Handle response and cleanup
        dialog.response.connect ((response_id) => {
            dialog.destroy ();
        });

        dialog.show ();
    }

    /*\
    * * Scores dialog
    \*/

    private Games.Scores.Context highscores;

    private inline void init_scores_dialog ()
    {
        var importer = new Games.Scores.DirectoryImporter ();
        highscores = new Games.Scores.Context.with_importer_and_icon_name ("five-or-more",
                                                                           /* Translators: text in the Scores dialog, introducing the combobox */
                                                                           _("Board Size: "),
                                                                           this,
                                                                           create_category_from_key,
                                                                           Games.Scores.Style.POINTS_GREATER_IS_BETTER,
                                                                           importer,
                                                                           "org.gnome.five-or-more");
        game.game_over.connect (score_cb);
    }

    private inline void score_cb ()
    {
        string name = category_name_from_key (game.score_current_category);
        var current_category = new Games.Scores.Category (game.score_current_category, name);
        highscores.add_score.begin (game.score,
                                    current_category,
                                    new Cancellable ());

        show_scores ();
    }

    private inline Games.Scores.Category? create_category_from_key (string key)
    {
        string? name = category_name_from_key (key);
        return new Games.Scores.Category (key, name);
    }

    private inline string category_name_from_key (string key)
    {
        for (int i = 0; i < game.n_categories; i++)
            if (Game.scorecats[i].key == key)
                return dpgettext2 (null, "board size", Game.scorecats[i].name); // C_() should work (and works if you rewrite every scorecat name here), but does not
        return "";
    }

    private inline void show_scores (/* SimpleAction action, Variant? parameter */)
    {
        highscores.run_dialog ();
    }

    /*\
    * * Appearance actions
    \*/

    private inline void change_background ()
    {
        string old_color_string = settings.get_string (FiveOrMoreApp.KEY_BACKGROUND_COLOR);
        /* Translators: title of the ColorChooser dialog that appears from the hamburger menu > "Appearance" submenu > "Background" section > "Select color" entry */
        ColorChooserDialog dialog = new ColorChooserDialog (_("Background color"), this);
        if (!dialog.rgba.parse (old_color_string))
            return;
        dialog.notify ["rgba"].connect ((dialog, param) => {
                var color = ((ColorChooserDialog) dialog).get_rgba ();
                if (!settings.set_string (FiveOrMoreApp.KEY_BACKGROUND_COLOR, color.to_string ()))
                    warning ("Failed to set color: %s", color.to_string ());
            });
        var result = dialog.run ();
        dialog.destroy ();
        if (result == ResponseType.OK)
            return;
        settings.set_string (FiveOrMoreApp.KEY_BACKGROUND_COLOR, old_color_string);
    }

    private inline void reset_background ()
    {
        settings.reset (FiveOrMoreApp.KEY_BACKGROUND_COLOR);
    }

    private inline void change_theme (SimpleAction action, Variant? parameter)
        requires (parameter != null)
    {
        action.set_state (parameter);
        settings.set_string (FiveOrMoreApp.KEY_THEME, ((!) parameter).get_string ());
    }

    /*\
    * * new game actions
    \*/

    private inline void change_size (SimpleAction action, Variant? parameter)
        requires (parameter != null)
    {
        int size;
        action.set_state (parameter);
        switch (parameter.get_string ()) {
            case "small":   size = 1;   break;
            case "medium":  size = 2;   break;
            case "large":   size = 3;   break;
            default: assert_not_reached ();
        }
        settings.set_int (FiveOrMoreApp.KEY_SIZE, size);
    }

    private inline void change_difficulty (SimpleAction action, Variant? parameter)
        requires (parameter != null)
    {
        int difficulty;
        action.set_state (parameter);
        switch (parameter.get_string ()) {
            case "easy":   difficulty = 0;   break;
            case "normal": difficulty = 1;   break;
            case "hard":   difficulty = 2;   break;
            default: assert_not_reached ();
        }
        settings.set_string (FiveOrMoreApp.KEY_DIFFICULTY, parameter.get_string ());

        // Update the game difficulty if a game is in progress
        if (game != null) {
            game.change_difficulty (difficulty);
        }
    }

    private inline void new_game (/* SimpleAction action, Variant? parameter */)
    {
        int size = settings.get_int (FiveOrMoreApp.KEY_SIZE);
        int n_rows = Game.game_difficulty[size].n_rows;
        int n_cols = Game.game_difficulty[size].n_cols;
        if (game.score > 0 && !game.is_game_over) {
            var flags = DialogFlags.DESTROY_WITH_PARENT;
            var restart_game_dialog = new MessageDialog (this,
                                                         flags,
                                                         MessageType.WARNING,
                                                         ButtonsType.NONE,
                                                         /* Translators: text of a dialog that appears when the user starts a new game while the score is not null */
                                                         _("Are you sure you want to start a new %u × %u game?").printf (n_rows, n_cols));

            /* Translators: button of a dialog that appears when the user starts a new game while the score is not null; the other answer is "_Restart" */
            restart_game_dialog.add_buttons (_("_Cancel"), ResponseType.CANCEL,

            /* Translators: button of a dialog that appears when the user starts a new game while the score is not null; the other answer is "_Cancel" */
                                             _("_Restart"), ResponseType.OK);

            var result = restart_game_dialog.run ();
            restart_game_dialog.destroy ();
            if (result != ResponseType.OK)
                return;
        }
        // Get current difficulty setting
        int difficulty_level = 1; // default to normal
        string difficulty_string = settings.get_string (FiveOrMoreApp.KEY_DIFFICULTY);
        switch (difficulty_string)
        {
            case "easy":   difficulty_level = 0; break;
            case "normal": difficulty_level = 1; break;
            case "hard":   difficulty_level = 2; break;
            default: difficulty_level = 1; break;
        }

        game.new_game (size, difficulty_level);
        score_display.reset_session ();
        if (score_button != null) {
            score_button.set_label ("Score: 0");
        }

        // Update sidebar panel with new game
        if (sidebar_panel != null) {
            sidebar_panel.set_game (game);
            sidebar_panel.on_new_game_started ();
        }
    }

    /*\
    * * Game Information Panel
    \*/

    private void setup_sidebar_panel ()
    {
        sidebar_panel = new TabbedSidebar (settings);
        sidebar_panel.set_game (game);

        // Connect sidebar panel to game events
        if (game != null) {
            game.board.grid_changed.connect (() => {
                if (sidebar_panel != null) {
                    sidebar_panel.on_game_state_changed ();
                }
            });

            // Connect line detection events for statistics and debugging
            game.line_detection_performed.connect ((row, col, had_lines, cells_removed) => {
                if (sidebar_panel != null) {
                    sidebar_panel.on_line_detection_with_count (row, col, had_lines, cells_removed);
                }
            });

            // Connect to game over events for final statistics
            game.game_over.connect (() => {
                if (sidebar_panel != null) {
                    sidebar_panel.on_game_ended (game.score);
                }
            });

            // Connect to score changes for real-time updates
            game.notify["score"].connect (() => {
                if (sidebar_panel != null) {
                    sidebar_panel.on_game_state_changed ();
                }
            });
        }
    }

    private Box? main_container = null;

    /*\
    * * Combo Mode Indicator Management
    \*/

    private void setup_combo_mode_indicators ()
    {
        indicator_manager = new ComboModeIndicatorManager (this, settings);

        // Ensure initial state consistency
        indicator_manager.ensure_indicator_consistency ();
    }

    private void toggle_combo_mode (/* SimpleAction action, Variant? parameter */)
    {
        if (indicator_manager == null) {
            setup_combo_mode_indicators ();
        }

        // Get current state and toggle it
        bool current_state = indicator_manager.get_combo_mode_active ();
        bool new_state = !current_state;

        // Update all indicators through the manager
        indicator_manager.update_indicators (new_state);

        // Show transition notification
        indicator_manager.show_mode_transition_notification (new_state);

        // Start a new game to apply the setting
        new_game ();
    }


    private void toggle_info_panel (/* SimpleAction action, Variant? parameter */)
    {
        if (sidebar_panel == null) {
            setup_sidebar_panel ();
        }

        // True toggle: simply flip the state
        sidebar_visible = !sidebar_visible;

        if (sidebar_visible) {
            show_sidebar_panel ();
        } else {
            hide_sidebar_panel ();
        }

        update_info_panel_button_state ();
    }

    private void show_sidebar_panel ()
    {
        // Only create container if it doesn't exist
        if (main_container == null) {
            main_container = new Box (Orientation.HORIZONTAL, 0);

            // Remove grid_frame from window and add to container
            remove (grid_frame);
            main_container.pack_start (grid_frame, true, true, 0);
            main_container.pack_start (sidebar_panel, false, false, 0);

            // Add container to window
            add (main_container);
        }

        // Always show the panel
        sidebar_panel.show ();
        main_container.show_all ();
    }

    private void hide_sidebar_panel ()
    {
        // Simply hide the panel, keep container structure
        if (sidebar_panel != null) {
            sidebar_panel.hide ();
        }
    }

    private void update_info_panel_button_state ()
    {
        if (info_panel_button != null) {
            if (sidebar_visible) {
                info_panel_button.get_style_context ().add_class ("suggested-action");
                info_panel_button.set_tooltip_text (_("Hide statistics panel"));
            } else {
                info_panel_button.get_style_context ().remove_class ("suggested-action");
                info_panel_button.set_tooltip_text (_("Show statistics panel"));
            }
        }
    }

    /**
     * Ensure the window always has content - emergency recovery method
     */
    private void ensure_window_has_content ()
    {
        var current_child = get_child ();
        if (current_child == null) {
            warning ("Window has no content, performing emergency recovery");

            // Reset state and add grid_frame back
            sidebar_visible = false;
            add (grid_frame);
            grid_frame.show ();
            update_info_panel_button_state ();
        }
    }
}
