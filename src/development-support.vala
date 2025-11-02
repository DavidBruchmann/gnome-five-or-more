/*
 * Five or More - Development Environment Support
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

/**
 * Development environment detection and configuration
 */
public class DevEnvironment : Object {
    private static DevEnvironment? instance = null;
    
    public bool is_development_mode { get; private set; default = false; }
    public bool hot_reload_enabled { get; private set; default = false; }
    public bool debug_logging_enabled { get; private set; default = false; }
    
    private string? custom_data_dir = null;
    private string? build_root_dir = null;
    private string? source_root_dir = null;
    
    // File monitoring for hot reload
    private HashTable<string, FileMonitor> file_monitors;
    
    // Signals for development features
    public signal void theme_file_changed(string file_path);
    public signal void development_mode_changed(bool enabled);
    public signal void hot_reload_toggled(bool enabled);
    
    construct {
        file_monitors = new HashTable<string, FileMonitor>(str_hash, str_equal);
        detect_development_environment();
    }
    
    /**
     * Get singleton instance
     */
    public static DevEnvironment get_instance() {
        if (instance == null) {
            instance = new DevEnvironment();
        }
        return instance;
    }
    
    /**
     * Detect if we're running in a development environment
     */
    private void detect_development_environment() {
        // Check for development environment variables
        custom_data_dir = Environment.get_variable("FIVE_OR_MORE_DATA_DIR");
        build_root_dir = Environment.get_variable("MESON_BUILD_ROOT");
        source_root_dir = Environment.get_variable("MESON_SOURCE_ROOT");
        
        // Check for development mode flag
        var dev_mode = Environment.get_variable("FIVE_OR_MORE_DEV_MODE");
        is_development_mode = (dev_mode != null && dev_mode == "1") ||
                             (build_root_dir != null) ||
                             (custom_data_dir != null);
        
        // Enable debug logging in development mode
        debug_logging_enabled = is_development_mode ||
                               Environment.get_variable("FIVE_OR_MORE_DEBUG") == "1";
        
        // Enable hot reload if explicitly requested
        var hot_reload = Environment.get_variable("FIVE_OR_MORE_HOT_RELOAD");
        hot_reload_enabled = hot_reload != null && hot_reload == "1";
        
        if (is_development_mode) {
            debug("Development mode detected");
            debug("  Custom data dir: %s", custom_data_dir ?? "none");
            debug("  Build root: %s", build_root_dir ?? "none");
            debug("  Source root: %s", source_root_dir ?? "none");
            debug("  Hot reload: %s", hot_reload_enabled ? "enabled" : "disabled");
        }
        
        development_mode_changed(is_development_mode);
    }
    
    /**
     * Get development-specific search paths
     */
    public string[] get_development_search_paths() {
        string[] paths = {};
        
        if (custom_data_dir != null) {
            paths += Path.build_filename(custom_data_dir, "themes");
            paths += Path.build_filename(custom_data_dir, "data", "themes");
        }
        
        if (build_root_dir != null) {
            paths += Path.build_filename(build_root_dir, "data", "themes");
            paths += Path.build_filename(build_root_dir, "themes");
        }
        
        if (source_root_dir != null) {
            paths += Path.build_filename(source_root_dir, "data", "themes");
            paths += Path.build_filename(source_root_dir, "themes");
        }
        
        // Check for relative paths from current working directory
        var cwd = Environment.get_current_dir();
        if (cwd != null) {
            paths += Path.build_filename(cwd, "data", "themes");
            paths += Path.build_filename(cwd, "themes");
            paths += Path.build_filename(cwd, "..", "data", "themes");
            paths += Path.build_filename(cwd, "..", "..", "data", "themes");
        }
        
        return paths;
    }
    
    /**
     * Enable or disable hot reload functionality
     */
    public void enable_hot_reload(bool enabled) {
        if (hot_reload_enabled == enabled) {
            return;
        }
        
        hot_reload_enabled = enabled;
        
        if (enabled) {
            setup_file_monitoring();
        } else {
            cleanup_file_monitoring();
        }
        
        hot_reload_toggled(enabled);
        debug("Hot reload %s", enabled ? "enabled" : "disabled");
    }
    
    /**
     * Setup file monitoring for hot reload
     */
    private void setup_file_monitoring() {
        if (!is_development_mode) {
            return;
        }
        
        var search_paths = get_development_search_paths();
        
        foreach (var path in search_paths) {
            var dir = File.new_for_path(path);
            if (!dir.query_exists()) {
                continue;
            }
            
            try {
                var monitor = dir.monitor_directory(FileMonitorFlags.NONE);
                monitor.changed.connect(on_file_changed);
                file_monitors.insert(path, monitor);
                debug("Monitoring directory for changes: %s", path);
            } catch (Error e) {
                warning("Failed to monitor directory %s: %s", path, e.message);
            }
        }
    }
    
    /**
     * Cleanup file monitoring
     */
    private void cleanup_file_monitoring() {
        file_monitors.foreach((path, monitor) => {
            monitor.cancel();
        });
        file_monitors.remove_all();
    }
    
    /**
     * Handle file change events
     */
    private void on_file_changed(File file, File? other_file, FileMonitorEvent event_type) {
        if (event_type != FileMonitorEvent.CHANGED && 
            event_type != FileMonitorEvent.CREATED) {
            return;
        }
        
        var file_path = file.get_path();
        if (file_path == null) {
            return;
        }
        
        // Only monitor theme-related files
        if (file_path.has_suffix(".svg") || 
            file_path.has_suffix(".xml") ||
            file_path.has_suffix(".css")) {
            
            debug("Theme file changed: %s", file_path);
            theme_file_changed(file_path);
        }
    }
    
    /**
     * Get diagnostic information for development debugging
     */
    public string get_development_diagnostic() {
        var builder = new StringBuilder();
        builder.append("Development Environment Diagnostic\n");
        builder.append("==================================\n\n");
        
        builder.append("Environment Detection:\n");
        builder.append("  Development mode: %s\n".printf(is_development_mode ? "YES" : "NO"));
        builder.append("  Hot reload: %s\n".printf(hot_reload_enabled ? "YES" : "NO"));
        builder.append("  Debug logging: %s\n".printf(debug_logging_enabled ? "YES" : "NO"));
        
        builder.append("\nEnvironment Variables:\n");
        builder.append("  FIVE_OR_MORE_DATA_DIR: %s\n".printf(custom_data_dir ?? "not set"));
        builder.append("  MESON_BUILD_ROOT: %s\n".printf(build_root_dir ?? "not set"));
        builder.append("  MESON_SOURCE_ROOT: %s\n".printf(source_root_dir ?? "not set"));
        builder.append("  FIVE_OR_MORE_DEV_MODE: %s\n".printf(
            Environment.get_variable("FIVE_OR_MORE_DEV_MODE") ?? "not set"));
        builder.append("  FIVE_OR_MORE_HOT_RELOAD: %s\n".printf(
            Environment.get_variable("FIVE_OR_MORE_HOT_RELOAD") ?? "not set"));
        builder.append("  FIVE_OR_MORE_DEBUG: %s\n".printf(
            Environment.get_variable("FIVE_OR_MORE_DEBUG") ?? "not set"));
        
        builder.append("\nDevelopment Search Paths:\n");
        var dev_paths = get_development_search_paths();
        foreach (var path in dev_paths) {
            var exists = FileUtils.test(path, FileTest.IS_DIR);
            builder.append("  %s %s\n".printf(exists ? "✓" : "✗", path));
        }
        
        builder.append("\nFile Monitoring:\n");
        builder.append("  Monitored directories: %u\n".printf(file_monitors.size()));
        file_monitors.foreach((path, monitor) => {
            builder.append("    %s\n".printf(path));
        });
        
        return builder.str;
    }
    
    /**
     * Create development configuration file
     */
    public void create_development_config() throws Error {
        if (!is_development_mode) {
            return;
        }
        
        var config_dir = Path.build_filename(Environment.get_home_dir(), ".config", "five-or-more");
        var config_file = Path.build_filename(config_dir, "development.conf");
        
        // Create config directory if it doesn't exist
        var dir = File.new_for_path(config_dir);
        if (!dir.query_exists()) {
            dir.make_directory_with_parents();
        }
        
        var config_content = new StringBuilder();
        config_content.append("# Five or More Development Configuration\n");
        config_content.append("# This file is automatically generated in development mode\n\n");
        
        config_content.append("[Environment]\n");
        config_content.append("development_mode=%s\n".printf(is_development_mode ? "true" : "false"));
        config_content.append("hot_reload=%s\n".printf(hot_reload_enabled ? "true" : "false"));
        config_content.append("debug_logging=%s\n".printf(debug_logging_enabled ? "true" : "false"));
        
        if (custom_data_dir != null) {
            config_content.append("custom_data_dir=%s\n".printf(custom_data_dir));
        }
        if (build_root_dir != null) {
            config_content.append("build_root_dir=%s\n".printf(build_root_dir));
        }
        if (source_root_dir != null) {
            config_content.append("source_root_dir=%s\n".printf(source_root_dir));
        }
        
        config_content.append("\n[Paths]\n");
        var dev_paths = get_development_search_paths();
        for (int i = 0; i < dev_paths.length; i++) {
            config_content.append("search_path_%d=%s\n".printf(i, dev_paths[i]));
        }
        
        FileUtils.set_contents(config_file, config_content.str);
        debug("Created development configuration: %s", config_file);
    }
    
    /**
     * Validate development environment setup
     */
    public bool validate_development_setup() {
        if (!is_development_mode) {
            return true; // Not in development mode, nothing to validate
        }
        
        var issues = new Gee.ArrayList<string>();
        
        // Check if any development paths exist
        var dev_paths = get_development_search_paths();
        bool any_path_exists = false;
        foreach (var path in dev_paths) {
            if (FileUtils.test(path, FileTest.IS_DIR)) {
                any_path_exists = true;
                break;
            }
        }
        
        if (!any_path_exists) {
            issues.add("No development theme directories found");
        }
        
        // Check for theme files in development paths
        bool theme_files_found = false;
        foreach (var path in dev_paths) {
            try {
                var dir = Dir.open(path);
                string? name;
                while ((name = dir.read_name()) != null) {
                    if (name.has_suffix(".svg")) {
                        theme_files_found = true;
                        break;
                    }
                }
            } catch (FileError e) {
                continue;
            }
            
            if (theme_files_found) {
                break;
            }
        }
        
        if (!theme_files_found) {
            issues.add("No SVG theme files found in development paths");
        }
        
        // Report issues
        if (issues.size > 0) {
            warning("Development environment validation issues:");
            foreach (var issue in issues) {
                warning("  - %s", issue);
            }
            return false;
        }
        
        debug("Development environment validation passed");
        return true;
    }
}

/**
 * Development debugging utilities
 */
public class DevelopmentDebugger : Object {
    private static DevelopmentDebugger? instance = null;
    
    private Gee.List<string> debug_messages;
    private uint max_debug_messages { get { return get_game_constants().MAX_DEBUG_LOG_MESSAGES; } }
    
    construct {
        debug_messages = new Gee.ArrayList<string>();
    }
    
    public static DevelopmentDebugger get_instance() {
        if (instance == null) {
            instance = new DevelopmentDebugger();
        }
        return instance;
    }
    
    /**
     * Log debug message with timestamp
     */
    public void log_debug(string message) {
        var timestamp = new DateTime.now_local().format("%H:%M:%S.%f");
        var formatted_message = "[%s] %s".printf(timestamp, message);
        
        debug_messages.add(formatted_message);
        
        // Cleanup old messages
        if (debug_messages.size > max_debug_messages) {
            debug_messages.remove_at(0);
        }
        
        // Also log to standard debug output
        debug("%s", message);
    }
    
    /**
     * Get recent debug messages
     */
    public string[] get_debug_messages(uint count = 50) {
        var start_index = int.max(0, (int)debug_messages.size - (int)count);
        var result = new string[int.min((int)count, debug_messages.size)];
        
        for (int i = 0; i < result.length; i++) {
            result[i] = debug_messages[start_index + i];
        }
        
        return result;
    }
    
    /**
     * Clear debug message history
     */
    public void clear_debug_messages() {
        debug_messages.clear();
    }
    
    /**
     * Export debug messages to file
     */
    public void export_debug_log(string file_path) throws Error {
        var content = new StringBuilder();
        content.append("Five or More Debug Log\n");
        content.append("Generated: %s\n\n".printf(new DateTime.now_local().format("%Y-%m-%d %H:%M:%S")));
        
        foreach (var message in debug_messages) {
            content.append("%s\n".printf(message));
        }
        
        FileUtils.set_contents(file_path, content.str);
    }
}