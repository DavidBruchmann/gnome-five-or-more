/*
 * Five or More - Combo Mode Visual Indicator Manager
 * Copyright © 2024 Five or More Contributors
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

/**
 * ComboModeIndicatorManager centralizes all visual indicator logic for combo mode state.
 * This class manages header bar indicators, menu state indicators, and mode transition notifications.
 */
internal class ComboModeIndicatorManager : Object {
    
    private GameWindow window;
    private GLib.Settings settings;
    private HeaderBar headerbar;
    
    // Visual indicator components
    private Gtk.Image? header_indicator = null;
    private SimpleAction? combo_action = null;
    
    // State tracking
    private bool combo_mode_active = false;
    private uint notification_timeout_id = 0;
    
    // Constants for visual indicators
    private const string COMBO_ICON_NAME = "preferences-system-symbolic";
    private const string COMBO_TOOLTIP_ACTIVE = _("Combo Play Mode Active - gap-separated patterns count as lines");
    private const int NOTIFICATION_DURATION_MS = 4000;
    
    /**
     * Creates a new ComboModeIndicatorManager instance
     * @param window The main game window
     * @param settings The GSettings instance for state persistence
     */
    public ComboModeIndicatorManager(GameWindow window, GLib.Settings settings) {
        this.window = window;
        this.settings = settings;
        this.headerbar = window.headerbar;
        
        // Initialize combo mode state from settings with error handling
        try {
            this.combo_mode_active = settings.get_boolean("enable-composite-lines");
        } catch (Error e) {
            warning("Failed to read enable-composite-lines setting: %s", e.message);
            this.combo_mode_active = false; // Default to traditional mode
        }
        
        // Set up all indicator components
        setup_header_indicator();
        setup_menu_action();
        
        // Connect to settings changes for external updates with error handling
        try {
            settings.changed["enable-composite-lines"].connect(on_settings_changed);
        } catch (Error e) {
            warning("Failed to connect to settings changes: %s", e.message);
        }
        
        // Initial state update
        update_all_indicators(combo_mode_active);
    }
    
    /**
     * Updates all visual indicators to reflect the current combo mode state
     * @param combo_active Whether combo mode is currently active
     */
    public void update_indicators(bool combo_active) {
        combo_mode_active = combo_active;
        
        // Update header bar indicator
        update_header_indicator(combo_active);
        
        // Update menu state indicator
        update_menu_state(combo_active);
        
        // Sync with settings if needed (with error handling)
        try {
            if (settings.get_boolean("enable-composite-lines") != combo_active) {
                settings.set_boolean("enable-composite-lines", combo_active);
            }
        } catch (Error e) {
            warning("Failed to sync combo mode setting: %s", e.message);
        }
        
        // Sync with game constants
        var constants = get_game_constants();
        constants.ENABLE_COMPOSITE_LINES = combo_active;
    }
    
    /**
     * Shows a mode transition notification with enhanced styling and accessibility
     * @param combo_active The new combo mode state
     */
    public void show_mode_transition_notification(bool combo_active) {
        string icon = combo_active ? "⚡" : "ℹ";
        string mode = combo_active ? _("Combo Play Mode") : _("Traditional Mode");
        string description = combo_active ? 
            _("gap-separated patterns now count as lines!") :
            _("only continuous lines count");
        
        string message = @"$icon $mode - $description";
        
        // Update header subtitle with enhanced styling
        headerbar.set_subtitle(message);
        
        // Clear any existing notification timeout
        if (notification_timeout_id != 0) {
            Source.remove(notification_timeout_id);
        }
        
        // Auto-hide after specified duration
        notification_timeout_id = Timeout.add(NOTIFICATION_DURATION_MS, () => {
            headerbar.set_subtitle(null);
            notification_timeout_id = 0;
            return Source.REMOVE;
        });
        
        // Announce to screen readers for accessibility
        announce_to_screen_reader(message);
    }
    
    /**
     * Sets up the header bar combo mode indicator
     */
    private void setup_header_indicator() {
        header_indicator = new Gtk.Image();
        header_indicator.set_from_icon_name(COMBO_ICON_NAME, Gtk.IconSize.BUTTON);
        header_indicator.set_tooltip_text(COMBO_TOOLTIP_ACTIVE);
        header_indicator.set_visible(false);
        
        // Add appropriate CSS classes for styling and accessibility
        header_indicator.get_style_context().add_class("combo-mode-indicator");
        
        // Set accessibility properties and keyboard navigation
        header_indicator.set_can_focus(true);
        
        var accessible = header_indicator.get_accessible();
        if (accessible != null) {
            accessible.set_name(_("Combo Mode Indicator"));
            accessible.set_description(COMBO_TOOLTIP_ACTIVE);
            accessible.set_role(Atk.Role.ICON);
        }
        
        // Add keyboard navigation support
        header_indicator.key_press_event.connect(on_indicator_key_press);
        header_indicator.button_press_event.connect(on_indicator_clicked);
        
        // Position the indicator appropriately in the header bar
        // Pack after the preview box but before the end-packed buttons
        headerbar.pack_start(header_indicator);
        
        // Ensure proper ordering by setting position
        headerbar.child_set_property(header_indicator, "position", 1);
    }
    
    /**
     * Sets up the menu action for stateful combo mode toggle
     */
    private void setup_menu_action() {
        // Look up the existing combo mode action
        combo_action = (SimpleAction) window.lookup_action("toggle-combo-mode");
        
        if (combo_action != null) {
            // Convert to stateful action if not already
            if (combo_action.get_state() == null) {
                // Create new stateful action to replace the existing one
                var new_action = new SimpleAction.stateful(
                    "toggle-combo-mode", 
                    null, 
                    new Variant.boolean(combo_mode_active)
                );
                
                // Connect the activation handler
                new_action.activate.connect(on_combo_action_activated);
                
                // Remove old action and add new one
                window.remove_action("toggle-combo-mode");
                window.add_action(new_action);
                combo_action = new_action;
            } else {
                // Action is already stateful, just connect handler
                combo_action.activate.connect(on_combo_action_activated);
            }
        }
    }
    
    /**
     * Updates the header bar indicator visibility and state
     * @param active Whether combo mode is active
     */
    private void update_header_indicator(bool active) {
        if (header_indicator != null) {
            header_indicator.set_visible(active);
            
            // Update tooltip and accessibility properties based on state
            if (active) {
                header_indicator.set_tooltip_text(COMBO_TOOLTIP_ACTIVE);
                
                // Update accessibility description
                var accessible = header_indicator.get_accessible();
                if (accessible != null) {
                    accessible.set_description(COMBO_TOOLTIP_ACTIVE);
                    accessible.set_role(Atk.Role.ICON);
                }
            }
        }
    }
    
    /**
     * Updates the menu state indicator
     * @param active Whether combo mode is active
     */
    private void update_menu_state(bool active) {
        if (combo_action != null) {
            combo_action.set_state(new Variant.boolean(active));
        }
    }
    
    /**
     * Updates all indicators to maintain consistency
     * @param active Whether combo mode is active
     */
    private void update_all_indicators(bool active) {
        update_header_indicator(active);
        update_menu_state(active);
    }
    
    /**
     * Handles combo mode action activation from menu
     */
    private void on_combo_action_activated() {
        // Toggle the state
        bool new_state = !combo_mode_active;
        
        // Update all indicators
        update_indicators(new_state);
        
        // Show transition notification
        show_mode_transition_notification(new_state);
    }
    
    /**
     * Handles external settings changes
     */
    private void on_settings_changed() {
        try {
            bool settings_state = settings.get_boolean("enable-composite-lines");
            if (settings_state != combo_mode_active) {
                update_indicators(settings_state);
            }
        } catch (Error e) {
            warning("Failed to handle settings change: %s", e.message);
        }
    }
    
    /**
     * Announces mode changes to screen readers for accessibility
     * @param message The message to announce
     */
    private void announce_to_screen_reader(string message) {
        // Announce through the window's accessible interface
        var window_accessible = window.get_accessible();
        if (window_accessible != null) {
            window_accessible.set_description(message);
            // Trigger announcement by changing a state
            window_accessible.notify_state_change(Atk.StateType.BUSY, false);
        }
        
        // Also announce through the header indicator if visible
        if (header_indicator != null && header_indicator.get_visible()) {
            var indicator_accessible = header_indicator.get_accessible();
            if (indicator_accessible != null) {
                indicator_accessible.set_description(message);
                indicator_accessible.notify_state_change(Atk.StateType.FOCUSED, combo_mode_active);
            }
        }
        
        // Log the announcement for debugging
        var live_message = @"Combo mode $(combo_mode_active ? "activated" : "deactivated"). $message";
        debug("Screen reader announcement: %s", live_message);
    }
    
    /**
     * Ensures indicator consistency with game state
     * This method can be called to validate and recover from inconsistent states
     */
    public void ensure_indicator_consistency() {
        try {
            bool settings_state = settings.get_boolean("enable-composite-lines");
            var constants = get_game_constants();
            bool constants_state = constants.ENABLE_COMPOSITE_LINES;
            
            // Check for inconsistencies
            if (settings_state != constants_state || settings_state != combo_mode_active) {
                debug("Combo mode indicator inconsistency detected - syncing states");
                
                // Use settings as the source of truth
                constants.ENABLE_COMPOSITE_LINES = settings_state;
                update_all_indicators(settings_state);
                combo_mode_active = settings_state;
            }
        } catch (Error e) {
            warning("Combo mode indicator sync failed: %s", e.message);
            // Fall back to safe state (traditional mode)
            var constants = get_game_constants();
            constants.ENABLE_COMPOSITE_LINES = false;
            update_all_indicators(false);
            combo_mode_active = false;
        }
    }
    
    /**
     * Gets the current combo mode state
     * @return true if combo mode is active, false otherwise
     */
    public bool get_combo_mode_active() {
        return combo_mode_active;
    }
    
    /**
     * Handles keyboard navigation on the header indicator
     * @param event The key press event
     * @return true if the event was handled
     */
    private bool on_indicator_key_press(Gdk.EventKey event) {
        // Handle Enter and Space keys to toggle combo mode
        if (event.keyval == Gdk.Key.Return || 
            event.keyval == Gdk.Key.space || 
            event.keyval == Gdk.Key.KP_Enter) {
            
            // Trigger combo mode toggle
            if (combo_action != null) {
                combo_action.activate(null);
            }
            return true;
        }
        
        return false;
    }
    
    /**
     * Handles mouse clicks on the header indicator
     * @param event The button press event
     * @return true if the event was handled
     */
    private bool on_indicator_clicked(Gdk.EventButton event) {
        // Handle left mouse button clicks
        if (event.button == 1 && event.type == Gdk.EventType.BUTTON_PRESS) {
            // Trigger combo mode toggle
            if (combo_action != null) {
                combo_action.activate(null);
            }
            return true;
        }
        
        return false;
    }
    
    /**
     * Cleanup method to remove timeouts and disconnect signals
     */
    public void cleanup() {
        if (notification_timeout_id != 0) {
            Source.remove(notification_timeout_id);
            notification_timeout_id = 0;
        }
        
        // Disconnect settings signal
        settings.changed["enable-composite-lines"].disconnect(on_settings_changed);
        
        // Disconnect indicator event handlers
        if (header_indicator != null) {
            header_indicator.key_press_event.disconnect(on_indicator_key_press);
            header_indicator.button_press_event.disconnect(on_indicator_clicked);
        }
    }
}