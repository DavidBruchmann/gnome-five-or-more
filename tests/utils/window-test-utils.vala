/*
 * Five or More - Window Testing Framework
 * Window-specific Test Utilities
 * 
 * This file provides utilities specifically for window testing.
 */

using Gtk;

namespace FiveOrMoreTest {

    /**
     * Utility class for window-specific testing operations
     */
    public class WindowTestUtils : GLib.Object {
        
        /**
         * Simulate a window resize event
         */
        public static void simulate_window_resize(ApplicationWindow window, int width, int height) {
            Test.message("Simulating window resize to %dx%d", width, height);
            
            window.resize(width, height);
            
            // Process pending events to ensure resize is handled
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            // Wait a bit for the resize to take effect
            var main_loop = new MainLoop();
            Timeout.add(100, () => {
                main_loop.quit();
                return false;
            });
            main_loop.run();
        }
        
        /**
         * Simulate window maximization
         */
        public static void simulate_window_maximize(ApplicationWindow window) {
            Test.message("Simulating window maximize");
            
            window.maximize();
            
            // Process events and wait for state change
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            var main_loop = new MainLoop();
            Timeout.add(200, () => {
                main_loop.quit();
                return false;
            });
            main_loop.run();
        }
        
        /**
         * Simulate window unmaximization
         */
        public static void simulate_window_unmaximize(ApplicationWindow window) {
            Test.message("Simulating window unmaximize");
            
            window.unmaximize();
            
            // Process events and wait for state change
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            var main_loop = new MainLoop();
            Timeout.add(200, () => {
                main_loop.quit();
                return false;
            });
            main_loop.run();
        }
        
        /**
         * Get HeaderBar from window
         */
        public static HeaderBar? get_window_headerbar(ApplicationWindow window) {
            return window.get_titlebar() as HeaderBar;
        }
        
        /**
         * Validate HeaderBar title
         */
        public static bool validate_headerbar_title(ApplicationWindow window, string expected_title) {
            var headerbar = get_window_headerbar(window);
            if (headerbar == null) {
                Test.message("HeaderBar not found in window");
                return false;
            }
            
            string actual_title = headerbar.get_title() ?? "";
            Test.message("HeaderBar title validation: expected '%s', actual '%s'", 
                        expected_title, actual_title);
            
            return actual_title == expected_title;
        }
        
        /**
         * Validate HeaderBar subtitle
         */
        public static bool validate_headerbar_subtitle(ApplicationWindow window, string expected_subtitle) {
            var headerbar = get_window_headerbar(window);
            if (headerbar == null) {
                Test.message("HeaderBar not found in window");
                return false;
            }
            
            string actual_subtitle = headerbar.get_subtitle() ?? "";
            Test.message("HeaderBar subtitle validation: expected '%s', actual '%s'", 
                        expected_subtitle, actual_subtitle);
            
            return actual_subtitle == expected_subtitle;
        }
        
        /**
         * Find child widget by type in container
         */
        public static Widget? find_child_widget_by_type(Container container, Type widget_type) {
            Widget? result = null;
            
            container.forall((widget) => {
                if (widget.get_type().is_a(widget_type)) {
                    result = widget;
                    return;
                }
                
                if (widget is Container) {
                    var child_result = find_child_widget_by_type(widget as Container, widget_type);
                    if (child_result != null) {
                        result = child_result;
                        return;
                    }
                }
            });
            
            return result;
        }
        
        /**
         * Generic find child widget function - removed due to Vala limitations
         * Use specific find_* methods instead
         */
        

        
        /**
         * Find HeaderBar in container
         */
        public static HeaderBar? find_headerbar(Container container) {
            return find_child_widget_by_type(container, typeof(HeaderBar)) as HeaderBar;
        }
        
        /**
         * Find Box in container
         */
        public static Box? find_box(Container container) {
            return find_child_widget_by_type(container, typeof(Box)) as Box;
        }
        
        /**
         * Find DrawingArea in container
         */
        public static DrawingArea? find_drawing_area(Container container) {
            return find_child_widget_by_type(container, typeof(DrawingArea)) as DrawingArea;
        }
        
        /**
         * Find MenuButton in container
         */
        public static MenuButton? find_menu_button(Container container) {
            return find_child_widget_by_type(container, typeof(MenuButton)) as MenuButton;
        }
        
        /**
         * Find Frame in container
         */
        public static Frame? find_frame(Container container) {
            return find_child_widget_by_type(container, typeof(Frame)) as Frame;
        }
        
        /**
         * Count widgets of specific type in container
         */
        public static int count_widgets_of_type(Container container, Type widget_type) {
            int count = 0;
            
            container.forall((widget) => {
                if (widget.get_type().is_a(widget_type)) {
                    count++;
                }
                
                if (widget is Container) {
                    count += count_widgets_of_type(widget as Container, widget_type);
                }
            });
            
            return count;
        }
        
        /**
         * Validate that required UI components are present
         * Requirements 1.3, 1.4, 1.5: GridFrame, NextPiecesWidget, MenuButton
         */
        public static bool validate_required_components(ApplicationWindow window) {
            Test.message("Validating required UI components (Requirements 1.3, 1.4, 1.5)");
            
            // Check HeaderBar
            var headerbar = get_window_headerbar(window);
            if (headerbar == null) {
                Test.message("✗ HeaderBar not found");
                return false;
            }
            Test.message("✓ HeaderBar found");
            
            // Check for Frame (simulating GridFrame - game board area) - Requirement 1.3
            var grid_frame = find_frame(window);
            if (grid_frame == null) {
                Test.message("✗ Frame (GridFrame) not found (Requirement 1.3)");
                return false;
            }
            Test.message("✓ Frame (GridFrame) found (Requirement 1.3)");
            
            // Check for NextPiecesWidget in HeaderBar - Requirement 1.4
            var preview_box = find_box(headerbar);
            if (preview_box == null) {
                Test.message("✗ Preview box not found in HeaderBar (Requirement 1.4)");
                return false;
            }
            
            // NextPiecesWidget is simulated by DrawingArea
            var drawing_area = find_drawing_area(preview_box);
            if (drawing_area == null) {
                Test.message("✗ NextPiecesWidget (DrawingArea) not found in HeaderBar (Requirement 1.4)");
                return false;
            }
            Test.message("✓ NextPiecesWidget found (Requirement 1.4)");
            
            // Check for MenuButton (hamburger menu) - Requirement 1.5
            var menu_button = find_menu_button(headerbar);
            if (menu_button == null) {
                Test.message("✗ MenuButton not found in HeaderBar (Requirement 1.5)");
                return false;
            }
            Test.message("✓ MenuButton found (Requirement 1.5)");
            
            return true;
        }
        
        /**
         * Simulate keyboard shortcut
         */
        public static void simulate_keyboard_shortcut(ApplicationWindow window, uint keyval, Gdk.ModifierType modifiers) {
            Test.message("Simulating keyboard shortcut: keyval=%u, modifiers=%u", keyval, modifiers);
            
            // For now, we'll just log the simulation since creating Gdk.EventKey is complex
            Test.message("Keyboard shortcut simulation not fully implemented yet");
            
            // Process events
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
        }
        
        /**
         * Wait for window to be fully realized and mapped
         */
        public static void wait_for_window_ready(ApplicationWindow window) {
            Test.message("Waiting for window to be ready");
            
            // Show the window if not already shown
            if (!window.get_visible()) {
                window.show_all();
            }
            
            // Wait for window to be realized
            while (!window.get_realized()) {
                while (Gtk.events_pending()) {
                    Gtk.main_iteration();
                }
                Thread.usleep(10000); // 10ms
            }
            
            // Wait for window to be mapped
            while (!window.get_mapped()) {
                while (Gtk.events_pending()) {
                    Gtk.main_iteration();
                }
                Thread.usleep(10000); // 10ms
            }
            
            // Process any remaining events
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            Test.message("Window is ready");
        }
        
        /**
         * Capture window screenshot for visual testing (if supported)
         */
        public static Gdk.Pixbuf? capture_window_screenshot(ApplicationWindow window) {
            if (!window.get_realized()) {
                Test.message("Cannot capture screenshot: window not realized");
                return null;
            }
            
            var gdk_window = window.get_window();
            if (gdk_window == null) {
                Test.message("Cannot capture screenshot: no GDK window");
                return null;
            }
            
            int width = window.get_allocated_width();
            int height = window.get_allocated_height();
            
            try {
                return Gdk.pixbuf_get_from_window(gdk_window, 0, 0, width, height);
            } catch (Error e) {
                Test.message("Failed to capture screenshot: %s", e.message);
                return null;
            }
        }
    }
    
    /**
     * Performance measurement utilities for window operations
     */
    public class WindowPerformanceUtils : GLib.Object {
        
        /**
         * Measure window creation time
         */
        public static double measure_window_creation_time(Gtk.Application app) {
            var timer = new Timer();
            timer.start();
            
            var window = new ApplicationWindow(app);
            app.add_window(window);
            window.show_all();
            
            // Wait for window to be fully realized
            WindowTestUtils.wait_for_window_ready(window);
            
            timer.stop();
            double elapsed = timer.elapsed();
            
            Test.message("Window creation time: %.3f seconds", elapsed);
            
            window.destroy();
            return elapsed;
        }
        
        /**
         * Measure window resize performance
         */
        public static double measure_window_resize_time(ApplicationWindow window, int width, int height) {
            var timer = new Timer();
            timer.start();
            
            WindowTestUtils.simulate_window_resize(window, width, height);
            
            timer.stop();
            double elapsed = timer.elapsed();
            
            Test.message("Window resize time: %.3f seconds", elapsed);
            return elapsed;
        }
    }
}