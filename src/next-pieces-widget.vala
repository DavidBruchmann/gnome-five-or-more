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

private class NextPiecesWidget : Gtk.DrawingArea
{
    private Settings settings;
    private Game? game;
    private ThemeRenderer? theme;
    private GameConstants constants;

    private Gee.ArrayList<Piece> local_pieces_queue;
    private int widget_height = -1;
    private int current_sprite_size;

    // Color names for tooltips - must match the order in layered-renderer.vala
    private string[] color_names = {
        _("Yellow"),    // 0: #FFFF00
        _("Purple"),    // 1: #FF00FF (Magenta)
        _("Green"),     // 2: #00FF00
        _("Red"),       // 3: #FF0000
        _("Blue"),      // 4: #0000FF
        _("Cyan"),      // 5: #00FFFF
        _("Orange")     // 6: #FF8000
    };

    internal NextPiecesWidget (Settings settings, Game game, ThemeRenderer theme)
    {
        this.settings = settings;
        this.game = game;
        this.theme = theme;
        this.constants = get_game_constants();

        // Use configurable sprite size
        current_sprite_size = constants.NEXT_PIECES_SIZE;

        set_queue_size ();
        settings.changed[FiveOrMoreApp.KEY_SIZE].connect (() => {
            set_queue_size ();
            queue_draw ();
        });

        local_pieces_queue = game.next_pieces_queue;
        queue_changed_cb (local_pieces_queue);

        game.queue_changed.connect (queue_changed_cb);

        // Enable mouse events for tooltips
        set_has_tooltip (constants.NEXT_PIECES_SHOW_TOOLTIPS);
        if (constants.NEXT_PIECES_SHOW_TOOLTIPS) {
            query_tooltip.connect (on_query_tooltip);
            motion_notify_event.connect (on_motion_notify);
            add_events (Gdk.EventMask.POINTER_MOTION_MASK);
        }
    }

    private void set_queue_size ()
    {
        current_sprite_size = constants.NEXT_PIECES_SIZE;
        set_size_request (current_sprite_size * game.n_next_pieces, current_sprite_size);
    }

    private void queue_changed_cb (Gee.ArrayList<Piece> next_pieces_queue)
    {
        local_pieces_queue = next_pieces_queue;
        queue_draw ();
    }

    protected override bool draw (Cairo.Context cr)
    {
        if (theme == null)
            return false;

        if (widget_height == -1)
        {
            widget_height = this.get_allocated_height ();
        }

        Gdk.RGBA background_color = Gdk.RGBA ();
        background_color.red = background_color.green = background_color.blue = background_color.alpha = 0;
        Gdk.cairo_set_source_rgba (cr, background_color);
        cr.paint ();

        for (int i = 0; i < local_pieces_queue.size; i++)
        {
            theme.render_sprite (cr,
                                 local_pieces_queue[i].id,
                                 0,
                                 i * current_sprite_size,
                                 (widget_height / 2) - (current_sprite_size / 2),
                                 current_sprite_size);

        }

        cr.stroke ();

        return true;
    }

    private bool on_motion_notify (Gdk.EventMotion event)
    {
        // Trigger tooltip update on mouse movement
        set_has_tooltip (constants.NEXT_PIECES_SHOW_TOOLTIPS);
        return false;
    }

    private bool on_query_tooltip (int x, int y, bool keyboard_mode, Gtk.Tooltip tooltip)
    {
        if (!constants.NEXT_PIECES_SHOW_TOOLTIPS || local_pieces_queue.size == 0)
            return false;

        // Determine which piece the mouse is over
        int piece_index = x / current_sprite_size;

        if (piece_index >= 0 && piece_index < local_pieces_queue.size) {
            var piece = local_pieces_queue[piece_index];

            // Get color name, with bounds checking
            string color_name;
            if (piece.id >= 0 && piece.id < color_names.length) {
                color_name = color_names[piece.id];
            } else {
                color_name = _("Unknown Color");
            }

            // Create tooltip text
            string tooltip_text = @"$(color_name)\n$(_("Next piece")) $(piece_index + 1)";
            tooltip.set_text (tooltip_text);

            // Set tooltip area to the specific piece
            Gdk.Rectangle rect = Gdk.Rectangle();
            rect.x = piece_index * current_sprite_size;
            rect.y = 0;
            rect.width = current_sprite_size;
            rect.height = get_allocated_height();
            tooltip.set_tip_area (rect);

            return true;
        }

        return false;
    }
}
