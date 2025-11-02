/*
 * Five or More - Hybrid Resource Loader
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
 * Resource loading priority levels for the hybrid loader
 */
public enum ResourcePriority {
    EMBEDDED,      // Highest priority - embedded GResources
    FILESYSTEM,    // Medium priority - external files
    FALLBACK       // Lowest priority - generated fallbacks
}

/**
 * Performance monitoring data for resource loading operations
 */
public class LoadingPerformanceData : Object {
    public ResourcePriority priority_used { get; set; }
    public TimeSpan load_time { get; set; }
    public uint64 resource_size { get; set; }
    public string resource_path { get; set; }
    public bool cache_hit { get; set; }
    public DateTime timestamp { get; set; }
    
    construct {
        timestamp = new DateTime.now_local();
    }
}

/**
 * Comprehensive error information for resource loading failures
 */
public errordomain ResourceLoadError {
    EMBEDDED_FAILED,
    FILESYSTEM_FAILED,
    FALLBACK_FAILED,
    ALL_METHODS_FAILED
}

/**
 * Extended error information for resource loading failures
 */
public class ResourceLoadErrorInfo : Object {
    public ResourcePriority failed_priority { get; set; }
    public string attempted_path { get; set; }
    public Error? underlying_error { get; set; }
    
    public ResourceLoadErrorInfo(ResourcePriority priority, string path, Error? cause = null) {
        this.failed_priority = priority;
        this.attempted_path = path;
        this.underlying_error = cause;
    }
}

/**
 * Hybrid resource loader that implements priority-based loading with comprehensive
 * error handling, performance monitoring, and timeout management
 */
public class HybridLoader : Object {
    private static HybridLoader? instance = null;
    
    // Performance monitoring
    private Gee.List<LoadingPerformanceData> performance_history;
    private HashTable<string, LoadingPerformanceData> performance_cache;
    
    // Error tracking
    private Gee.List<ResourceLoadErrorInfo> error_history;
    private uint max_error_history = 100;
    
    // Timeout configuration
    private uint timeout_ms = 5000; // 5 second default timeout
    
    // Path resolution configuration
    private string[] search_paths;
    private string[] embedded_prefixes;
    
    // Signals for monitoring and debugging
    public signal void resource_loaded(string resource_name, ResourcePriority priority, TimeSpan load_time);
    public signal void resource_load_failed(string resource_name, ResourcePriority priority, Error error);
    public signal void performance_threshold_exceeded(string resource_name, TimeSpan load_time);
    
    construct {
        performance_history = new Gee.ArrayList<LoadingPerformanceData>();
        performance_cache = new HashTable<string, LoadingPerformanceData>(str_hash, str_equal);
        error_history = new Gee.ArrayList<ResourceLoadErrorInfo>();
        
        initialize_search_paths();
        initialize_embedded_prefixes();
        setup_development_integration();
    }
    
    /**
     * Get singleton instance of HybridLoader
     */
    public static HybridLoader get_instance() {
        if (instance == null) {
            instance = new HybridLoader();
        }
        return instance;
    }
    
    /**
     * Initialize filesystem search paths based on deployment scenario
     */
    private void initialize_search_paths() {
        search_paths = {};
        
        // Get development environment instance
        var dev_env = DevEnvironment.get_instance();
        
        // Add development-specific paths first (highest priority)
        if (dev_env.is_development_mode) {
            var dev_paths = dev_env.get_development_search_paths();
            foreach (var path in dev_paths) {
                search_paths += path;
            }
            debug("Added %d development search paths", dev_paths.length);
        }
        
        // Standard installation paths
        search_paths += Path.build_filename(DATA_DIRECTORY, "themes");
        
        // System-wide fallback paths
        search_paths += "/usr/share/five-or-more/themes";
        search_paths += "/usr/local/share/five-or-more/themes";
        
        debug("Initialized %d total search paths", search_paths.length);
    }
    
    /**
     * Initialize embedded resource prefixes
     */
    private void initialize_embedded_prefixes() {
        embedded_prefixes = {
            "/org/gnome/five-or-more/themes",
            "/org/gnome/five-or-more/resources",
            "/org/gnome/five-or-more"
        };
    }
    
    /**
     * Setup integration with development environment
     */
    private void setup_development_integration() {
        var dev_env = DevEnvironment.get_instance();
        
        // Connect to development environment signals
        dev_env.theme_file_changed.connect(on_theme_file_changed);
        dev_env.development_mode_changed.connect(on_development_mode_changed);
        
        // Setup hot reload if enabled
        if (dev_env.hot_reload_enabled) {
            debug("Hot reload enabled for HybridLoader");
        }
    }
    
    /**
     * Handle theme file changes for hot reload
     */
    private void on_theme_file_changed(string file_path) {
        debug("Theme file changed, invalidating cache: %s", file_path);
        
        // Clear performance cache for affected resources
        var file_name = Path.get_basename(file_path);
        performance_cache.remove(file_name);
        
        // Emit signal for theme system to reload
        resource_loaded(file_name, ResourcePriority.FILESYSTEM, 0);
    }
    
    /**
     * Handle development mode changes
     */
    private void on_development_mode_changed(bool enabled) {
        if (enabled) {
            debug("Development mode enabled, reinitializing search paths");
            initialize_search_paths();
        }
    }
    
    /**
     * Load a resource using priority-based loading with comprehensive error handling
     */
    public async Bytes load_resource_async(string resource_name, Cancellable? cancellable = null) throws Error {
        var start_time = get_monotonic_time();
        var performance_data = new LoadingPerformanceData();
        performance_data.resource_path = resource_name;
        
        // Check performance cache first
        var cached_perf = performance_cache.lookup(resource_name);
        if (cached_perf != null && cached_perf.cache_hit) {
            performance_data.cache_hit = true;
        }
        
        try {
            // Priority 1: Try embedded resources
            try {
                var result = yield load_from_embedded_async(resource_name, cancellable);
                performance_data.priority_used = ResourcePriority.EMBEDDED;
                performance_data.resource_size = result.length;
                record_successful_load(performance_data, start_time);
                return result;
            } catch (Error e) {
                record_load_error(ResourcePriority.EMBEDDED, resource_name, e);
                debug("Embedded resource load failed for %s: %s", resource_name, e.message);
            }
            
            // Priority 2: Try filesystem
            try {
                var result = yield load_from_filesystem_async(resource_name, cancellable);
                performance_data.priority_used = ResourcePriority.FILESYSTEM;
                performance_data.resource_size = result.length;
                record_successful_load(performance_data, start_time);
                return result;
            } catch (Error e) {
                record_load_error(ResourcePriority.FILESYSTEM, resource_name, e);
                debug("Filesystem resource load failed for %s: %s", resource_name, e.message);
            }
            
            // Priority 3: Generate fallback
            try {
                var result = yield generate_fallback_async(resource_name, cancellable);
                performance_data.priority_used = ResourcePriority.FALLBACK;
                performance_data.resource_size = result.length;
                record_successful_load(performance_data, start_time);
                warning("Using fallback resource for %s", resource_name);
                return result;
            } catch (Error e) {
                record_load_error(ResourcePriority.FALLBACK, resource_name, e);
                throw new ResourceLoadError.ALL_METHODS_FAILED(
                    "All resource loading methods failed for %s: %s".printf(resource_name, e.message)
                );
            }
        } finally {
            // Always record performance data
            performance_data.load_time = get_monotonic_time() - start_time;
            performance_history.add(performance_data);
            performance_cache.insert(resource_name, performance_data);
            
            // Emit performance signals
            resource_loaded(resource_name, performance_data.priority_used, performance_data.load_time);
            
            if (performance_data.load_time > timeout_ms * 1000) {
                performance_threshold_exceeded(resource_name, performance_data.load_time);
            }
        }
    }
    
    /**
     * Synchronous version of resource loading
     */
    public Bytes load_resource(string resource_name) throws Error {
        var main_loop = new MainLoop();
        Bytes? result = null;
        Error? error = null;
        
        load_resource_async.begin(resource_name, null, (obj, res) => {
            try {
                result = load_resource_async.end(res);
            } catch (Error e) {
                error = e;
            }
            main_loop.quit();
        });
        
        var timeout_source = Timeout.add(timeout_ms, () => {
            error = new IOError.TIMED_OUT("Resource loading timed out after %u ms".printf(timeout_ms));
            main_loop.quit();
            return false;
        });
        
        main_loop.run();
        Source.remove(timeout_source);
        
        if (error != null) {
            throw error;
        }
        
        return result;
    }
    
    /**
     * Load resource from embedded GResources
     */
    private async Bytes load_from_embedded_async(string resource_name, Cancellable? cancellable) throws Error {
        foreach (var prefix in embedded_prefixes) {
            var resource_path = Path.build_filename(prefix, resource_name);
            
            try {
                var resource = resources_lookup_data(resource_path, ResourceLookupFlags.NONE);
                debug("Successfully loaded embedded resource: %s", resource_path);
                return resource;
            } catch (Error e) {
                debug("Failed to load from %s: %s", resource_path, e.message);
                continue;
            }
        }
        
        throw new IOError.NOT_FOUND("Resource %s not found in embedded resources".printf(resource_name));
    }
    
    /**
     * Load resource from filesystem
     */
    private async Bytes load_from_filesystem_async(string resource_name, Cancellable? cancellable) throws Error {
        foreach (var search_path in search_paths) {
            var file_path = Path.build_filename(search_path, resource_name);
            var file = File.new_for_path(file_path);
            
            try {
                if (!file.query_exists(cancellable)) {
                    continue;
                }
                
                var file_info = yield file.query_info_async(
                    FileAttribute.STANDARD_SIZE,
                    FileQueryInfoFlags.NONE,
                    Priority.DEFAULT,
                    cancellable
                );
                
                var size = file_info.get_size();
                if (size > 10 * 1024 * 1024) { // 10MB limit
                    throw new IOError.INVALID_DATA("Resource file too large: %s (%lld bytes)".printf(file_path, size));
                }
                
                uint8[] contents;
                string etag;
                yield file.load_contents_async(cancellable, out contents, out etag);
                debug("Successfully loaded filesystem resource: %s (%lld bytes)", file_path, size);
                return new Bytes(contents);
            } catch (Error e) {
                debug("Failed to load from %s: %s", file_path, e.message);
                continue;
            }
        }
        
        throw new IOError.NOT_FOUND("Resource %s not found in filesystem paths".printf(resource_name));
    }
    
    /**
     * Generate fallback resource when all other methods fail
     */
    private async Bytes generate_fallback_async(string resource_name, Cancellable? cancellable) throws Error {
        // For SVG theme files, generate a minimal fallback
        if (resource_name.has_suffix(".svg")) {
            var fallback_svg = create_fallback_svg_theme();
            return new Bytes(fallback_svg.data);
        }
        
        // For other resources, create empty content with appropriate headers
        if (resource_name.has_suffix(".xml")) {
            var fallback_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<fallback/>";
            return new Bytes(fallback_xml.data);
        }
        
        throw new IOError.NOT_SUPPORTED("Cannot generate fallback for resource type: %s".printf(resource_name));
    }
    
    /**
     * Create a minimal fallback SVG theme
     */
    private string create_fallback_svg_theme() {
        return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="700" version="1.1">
  <style>
    .piece { stroke: #000000; stroke-width: 2; }
    .piece-0 { fill: #FFFF00; }
    .piece-1 { fill: #FF00FF; }
    .piece-2 { fill: #00FF00; }
    .piece-3 { fill: #FF0000; }
    .piece-4 { fill: #0000FF; }
    .piece-5 { fill: #00FFFF; }
    .piece-6 { fill: #FF8000; }
  </style>
  <g>
    <!-- Fallback theme with simple circles -->
    <circle class="piece piece-0" cx="50" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="150" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="250" cy="50" r="37.5"/>
    <circle class="piece piece-0" cx="350" cy="50" r="37.5"/>
    
    <circle class="piece piece-1" cx="50" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="150" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="250" cy="150" r="37.5"/>
    <circle class="piece piece-1" cx="350" cy="150" r="37.5"/>
    
    <circle class="piece piece-2" cx="50" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="150" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="250" cy="250" r="37.5"/>
    <circle class="piece piece-2" cx="350" cy="250" r="37.5"/>
    
    <circle class="piece piece-3" cx="50" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="150" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="250" cy="350" r="37.5"/>
    <circle class="piece piece-3" cx="350" cy="350" r="37.5"/>
    
    <circle class="piece piece-4" cx="50" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="150" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="250" cy="450" r="37.5"/>
    <circle class="piece piece-4" cx="350" cy="450" r="37.5"/>
    
    <circle class="piece piece-5" cx="50" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="150" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="250" cy="550" r="37.5"/>
    <circle class="piece piece-5" cx="350" cy="550" r="37.5"/>
    
    <circle class="piece piece-6" cx="50" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="150" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="250" cy="650" r="37.5"/>
    <circle class="piece piece-6" cx="350" cy="650" r="37.5"/>
  </g>
</svg>""";
    }
    
    /**
     * Record successful resource load for performance monitoring
     */
    private void record_successful_load(LoadingPerformanceData data, int64 start_time) {
        data.load_time = get_monotonic_time() - start_time;
        
        // Cleanup old performance history
        if (performance_history.size > 1000) {
            performance_history.remove_at(0);
        }
    }
    
    /**
     * Record resource loading error for debugging
     */
    private void record_load_error(ResourcePriority priority, string resource_name, Error error) {
        var load_error = new ResourceLoadErrorInfo(priority, resource_name, error);
        error_history.add(load_error);
        
        // Cleanup old error history
        if (error_history.size > max_error_history) {
            error_history.remove_at(0);
        }
        
        resource_load_failed(resource_name, priority, error);
    }
    
    /**
     * Get performance statistics for monitoring and optimization
     */
    public LoadingPerformanceData[] get_performance_statistics() {
        return performance_history.to_array();
    }
    
    /**
     * Get recent error history for debugging
     */
    public ResourceLoadErrorInfo[] get_error_history() {
        return error_history.to_array();
    }
    
    /**
     * Configure timeout for resource loading operations
     */
    public void set_timeout(uint timeout_milliseconds) {
        this.timeout_ms = timeout_milliseconds;
    }
    
    /**
     * Add custom search path for development/testing
     */
    public void add_search_path(string path) {
        if (!(path in search_paths)) {
            search_paths += path;
            debug("Added custom search path: %s", path);
        }
    }
    
    /**
     * Clear performance and error history
     */
    public void clear_history() {
        performance_history.clear();
        performance_cache.remove_all();
        error_history.clear();
    }
    
    /**
     * Get diagnostic information for troubleshooting
     */
    public string get_diagnostic_info() {
        var builder = new StringBuilder();
        builder.append("HybridLoader Diagnostic Information\n");
        builder.append("=====================================\n\n");
        
        builder.append("Search Paths:\n");
        foreach (var path in search_paths) {
            var exists = FileUtils.test(path, FileTest.IS_DIR);
            builder.append("  %s %s\n".printf(exists ? "✓" : "✗", path));
        }
        
        builder.append("\nEmbedded Prefixes:\n");
        foreach (var prefix in embedded_prefixes) {
            builder.append("  %s\n".printf(prefix));
        }
        
        builder.append("\nPerformance Summary:\n");
        builder.append("  Total loads: %d\n".printf(performance_history.size));
        builder.append("  Recent errors: %d\n".printf(error_history.size));
        builder.append("  Timeout: %u ms\n".printf(timeout_ms));
        
        if (performance_history.size > 0) {
            TimeSpan total_time = 0;
            var embedded_count = 0;
            var filesystem_count = 0;
            var fallback_count = 0;
            
            foreach (var perf in performance_history) {
                total_time += perf.load_time;
                switch (perf.priority_used) {
                    case ResourcePriority.EMBEDDED:
                        embedded_count++;
                        break;
                    case ResourcePriority.FILESYSTEM:
                        filesystem_count++;
                        break;
                    case ResourcePriority.FALLBACK:
                        fallback_count++;
                        break;
                }
            }
            
            var avg_time = total_time / performance_history.size;
            builder.append("  Average load time: %.2f ms\n".printf(avg_time / 1000.0));
            builder.append("  Embedded: %d, Filesystem: %d, Fallback: %d\n".printf(
                embedded_count, filesystem_count, fallback_count));
        }
        
        return builder.str;
    }
}