# Combo Mode Visual Indicators - Design

## Overview

This design document outlines the implementation of visual indicators for the combo mode toggle feature in Five or More. The solution provides clear visual feedback through menu state indicators and a header bar icon, ensuring users always know which game mode is active.

## Architecture

The visual indicator system consists of three main components:

1. **Menu State Indicator**: Checkmark or similar visual cue in the hamburger menu
2. **Header Bar Mode Indicator**: Icon displayed in the header bar when combo mode is active
3. **Mode Transition Feedback**: Enhanced notification system for mode changes

The implementation leverages the existing GSettings system for state persistence and integrates seamlessly with the current UI structure.

## Components and Interfaces

### 1. ComboModeIndicatorManager

A new class responsible for managing all visual indicators related to combo mode state.

```vala
public class ComboModeIndicatorManager : Object {
    private GameWindow window;
    private GLib.Settings settings;
    private Gtk.Image? header_indicator = null;
    private bool combo_mode_active = false;
    
    public ComboModeIndicatorManager(GameWindow window, GLib.Settings settings);
    public void update_indicators(bool combo_active);
    public void setup_header_indicator();
    public void show_mode_transition_notification(bool combo_active);
}
```

### 2. Enhanced Menu System

The existing menu system will be enhanced to show state indicators:

- **Current State**: Simple menu item with no visual feedback
- **Enhanced State**: Menu item with checkmark/indicator when combo mode is active
- **Implementation**: Use GAction state to control menu item appearance

### 3. Header Bar Integration

The header bar will include a conditional combo mode indicator:

- **Position**: Between the "Next:" preview and the Info/Menu buttons
- **Icon**: A distinctive symbol representing combo/advanced gameplay (e.g., "⚡" or custom SVG)
- **Visibility**: Only shown when combo mode is active
- **Tooltip**: "Combo Play Mode Active - gap-separated patterns count as lines"

### 4. Enhanced Notification System

Building on the existing `show_temporary_message()` function:

- **Duration**: 4 seconds (increased from 3 for better readability)
- **Styling**: Distinct visual treatment for mode change notifications
- **Content**: Clear indication of current mode and its effects
- **Accessibility**: Screen reader announcements for mode changes

## Data Models

### Settings Integration

The existing GSettings schema already supports combo mode state:

```xml
<key name="enable-composite-lines" type="b">
  <default>false</default>
  <summary>Enable combo play mode</summary>
  <description>Enable combo play mode that allows gap-separated patterns...</description>
</key>
```

### State Management

```vala
public class ComboModeState : Object {
    public bool is_active { get; set; default = false; }
    public signal void mode_changed(bool new_state);
    
    public void toggle() {
        is_active = !is_active;
        mode_changed(is_active);
    }
}
```

## User Interface Design

### Header Bar Layout

```
[Title: Five or More]  [Next: ●●●]  [⚡]  [Info]  [☰]
                                     ↑
                              Combo indicator
                           (only when active)
```

### Menu State Visualization

```
☰ Menu
├── New Game
├── Size ▶
├── Difficulty ▶
├── Scores
├── Appearance ▶
├── ✓ Combo Play    ← Checkmark when active
└── Game Info
```

### Notification Design

**Traditional Mode Activation:**
```
[ℹ] Traditional Mode - only continuous lines count
```

**Combo Mode Activation:**
```
[⚡] Combo Play Mode - gap-separated patterns now count as lines!
```

## Implementation Details

### 1. Header Bar Indicator

```vala
private void setup_combo_indicator() {
    combo_indicator = new Gtk.Image();
    combo_indicator.set_from_icon_name("emblem-system-symbolic", Gtk.IconSize.BUTTON);
    combo_indicator.set_tooltip_text("Combo Play Mode Active");
    combo_indicator.set_visible(false);
    
    // Add to header bar between preview and buttons
    headerbar.pack_start(combo_indicator);
}

private void update_combo_indicator(bool active) {
    if (combo_indicator != null) {
        combo_indicator.set_visible(active);
    }
}
```

### 2. Menu State Integration

```vala
private void setup_combo_menu_action() {
    var combo_action = new SimpleAction.stateful(
        "toggle-combo-mode", 
        null, 
        new Variant.boolean(false)
    );
    
    combo_action.activate.connect(() => {
        bool current_state = combo_action.get_state().get_boolean();
        bool new_state = !current_state;
        combo_action.set_state(new Variant.boolean(new_state));
        apply_combo_mode_change(new_state);
    });
    
    add_action(combo_action);
}
```

### 3. Enhanced UI File

```xml
<item>
  <attribute name="label" translatable="yes">_Combo Play</attribute>
  <attribute name="action">win.toggle-combo-mode</attribute>
  <attribute name="role">check</attribute>
</item>
```

### 4. Notification Enhancement

```vala
private void show_combo_mode_notification(bool combo_active) {
    string icon = combo_active ? "⚡" : "ℹ";
    string mode = combo_active ? "Combo Play Mode" : "Traditional Mode";
    string description = combo_active ? 
        "gap-separated patterns now count as lines!" :
        "only continuous lines count";
    
    string message = @"$icon $mode - $description";
    
    // Update header subtitle with enhanced styling
    headerbar.set_subtitle(message);
    
    // Auto-hide after 4 seconds
    Timeout.add(4000, () => {
        headerbar.set_subtitle(null);
        return Source.REMOVE;
    });
    
    // Announce to screen readers
    announce_to_screen_reader(message);
}
```

## Error Handling

### Graceful Degradation

1. **Missing Icons**: Fall back to text-based indicators if custom icons are unavailable
2. **UI Layout Issues**: Ensure indicators don't break existing layout if positioning fails
3. **Settings Corruption**: Default to traditional mode if settings are invalid
4. **Memory Constraints**: Clean up indicator resources when not needed

### Error Recovery Strategies

```vala
private void ensure_indicator_consistency() {
    try {
        bool settings_state = settings.get_boolean("enable-composite-lines");
        bool constants_state = get_game_constants().ENABLE_COMPOSITE_LINES;
        
        if (settings_state != constants_state) {
            // Sync states and update indicators
            settings.set_boolean("enable-composite-lines", constants_state);
            update_all_indicators(constants_state);
        }
    } catch (Error e) {
        warning("Combo mode indicator sync failed: %s", e.message);
        // Fall back to safe state
        update_all_indicators(false);
    }
}
```

## Testing Strategy

### Unit Tests

1. **Indicator State Management**: Test that indicators update correctly when mode changes
2. **Settings Integration**: Verify that visual state matches settings state
3. **Menu Integration**: Test that menu items show correct state indicators
4. **Notification System**: Verify that notifications appear and disappear correctly

### Integration Tests

1. **Full Mode Toggle Flow**: Test complete user interaction from menu click to visual feedback
2. **Persistence Testing**: Verify that indicator state persists across application restarts
3. **Accessibility Testing**: Test screen reader announcements and keyboard navigation
4. **Visual Regression**: Ensure indicators don't break existing UI layout

### User Experience Tests

1. **Clarity Testing**: Verify that users can easily identify current mode
2. **Discoverability**: Test that new users can find and understand the indicators
3. **Consistency**: Ensure visual language matches other application indicators
4. **Performance**: Verify that indicators don't impact game performance

## Accessibility Considerations

### Screen Reader Support

```vala
private void announce_to_screen_reader(string message) {
    var accessible = get_accessible();
    if (accessible != null) {
        accessible.set_description(message);
        // Trigger announcement
        accessible.notify_state_change(Atk.StateType.BUSY, false);
    }
}
```

### Keyboard Navigation

- Ensure combo mode toggle is accessible via keyboard navigation
- Provide keyboard shortcuts for quick mode switching (optional)
- Maintain focus management when indicators change

### High Contrast Support

- Use system theme colors for indicators
- Ensure sufficient contrast ratios for all indicator states
- Support custom theme variations

## Performance Considerations

### Resource Management

- Use lightweight icons and minimal memory footprint
- Cache indicator resources to avoid repeated loading
- Clean up unused indicator elements

### Update Efficiency

- Only update indicators when state actually changes
- Batch multiple indicator updates when possible
- Avoid unnecessary redraws of unchanged elements

### Startup Performance

- Initialize indicators lazily when first needed
- Don't block application startup for indicator setup
- Use async loading for any external resources

This design provides a comprehensive solution for combo mode visual indicators that enhances user experience while maintaining the application's performance and accessibility standards.