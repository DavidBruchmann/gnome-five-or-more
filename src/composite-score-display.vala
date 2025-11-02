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

/**
 * Achievement record for composite lines
 */
internal class CompositeAchievement : Object {
    public Gee.ArrayList<CompositeLine> lines { get; set; }
    public int score { get; set; }
    public string description { get; set; }
    public DateTime timestamp { get; set; }
    
    public CompositeAchievement(Gee.ArrayList<CompositeLine> lines, int score, string description) {
        this.lines = lines;
        this.score = score;
        this.description = description;
        this.timestamp = new DateTime.now_local();
    }
    
    public string get_short_description() {
        if (lines.size == 1) {
            return lines[0].get_pattern_description();
        } else {
            return @"$(lines.size) lines cleared";
        }
    }
}

/**
 * Manages display of composite line scoring and achievements
 */
internal class CompositeScoreDisplay : Object {
    private Gee.ArrayList<CompositeAchievement> recent_achievements;
    public int current_score { get; private set; default = 0; }
    private int session_composite_score = 0;
    private int total_composite_lines = 0;
    
    // Statistics tracking
    private HashTable<string, int> pattern_counts;
    private int best_single_score = 0;
    private string best_pattern = "";
    
    construct {
        recent_achievements = new Gee.ArrayList<CompositeAchievement>();
        pattern_counts = new HashTable<string, int>(str_hash, str_equal);
    }
    
    /**
     * Update the current score
     */
    public void update_score(int score) {
        current_score = score;
    }
    
    /**
     * Show a composite line achievement
     */
    public void show_composite_achievement(Gee.ArrayList<CompositeLine> lines, int score, string description) {
        var achievement = new CompositeAchievement(lines, score, description);
        recent_achievements.add(achievement);
        
        // Keep only recent achievements (last 10)
        while (recent_achievements.size > 10) {
            recent_achievements.remove_at(0);
        }
        
        // Update statistics
        session_composite_score += score;
        total_composite_lines += lines.size;
        
        foreach (var line in lines) {
            string pattern = line.get_pattern_description();
            int current_count = pattern_counts.contains(pattern) ? pattern_counts.lookup(pattern) : 0;
            pattern_counts.insert(pattern, current_count + 1);
            
            if (score > best_single_score) {
                best_single_score = score;
                best_pattern = pattern;
            }
        }
        
        // Emit signal for UI updates
        achievement_recorded(achievement);
    }
    
    /**
     * Get recent achievements for display
     */
    public Gee.ArrayList<CompositeAchievement> get_recent_achievements() {
        return recent_achievements;
    }
    
    /**
     * Get score breakdown information
     */
    public string get_score_breakdown() {
        var breakdown = new StringBuilder();
        breakdown.append(@"Current Score: $(current_score)\n");
        
        if (session_composite_score > 0) {
            breakdown.append(@"Composite Lines Score: $(session_composite_score)\n");
            breakdown.append(@"Total Composite Lines: $(total_composite_lines)\n");
            
            if (best_single_score > 0) {
                breakdown.append(@"Best Achievement: $(best_pattern) ($(best_single_score) points)\n");
            }
        }
        
        return breakdown.str;
    }
    
    /**
     * Get pattern statistics
     */
    public string get_pattern_statistics() {
        if (pattern_counts.size() == 0) {
            return "No composite lines achieved yet.";
        }
        
        var stats = new StringBuilder();
        stats.append("Composite Line Patterns:\n");
        
        pattern_counts.foreach((pattern, count) => {
            stats.append(@"• $(pattern): $(count) times\n");
        });
        
        return stats.str;
    }
    
    /**
     * Reset statistics for new game
     */
    public void reset_session() {
        recent_achievements.clear();
        session_composite_score = 0;
        total_composite_lines = 0;
        pattern_counts.remove_all();
        best_single_score = 0;
        best_pattern = "";
        current_score = 0;
    }
    
    /**
     * Get achievement summary for the session
     */
    public string get_session_summary() {
        if (total_composite_lines == 0) {
            return "No composite lines achieved this session.";
        }
        
        var summary = new StringBuilder();
        summary.append(@"Session Summary:\n");
        summary.append(@"• Composite lines cleared: $(total_composite_lines)\n");
        summary.append(@"• Points from composite lines: $(session_composite_score)\n");
        summary.append(@"• Different patterns achieved: $(pattern_counts.size())\n");
        
        if (best_single_score > 0) {
            summary.append(@"• Best single achievement: $(best_pattern) ($(best_single_score) points)\n");
        }
        
        return summary.str;
    }
    
    /**
     * Check if this is a notable achievement
     */
    public bool is_notable_achievement(CompositeAchievement achievement) {
        // Notable if it's a new best score
        if (achievement.score >= best_single_score) {
            return true;
        }
        
        // Notable if it's a complex pattern (3+ segments)
        foreach (var line in achievement.lines) {
            if (line.segments.size >= 3) {
                return true;
            }
        }
        
        // Notable if multiple lines cleared simultaneously
        if (achievement.lines.size > 1) {
            return true;
        }
        
        return false;
    }
    
    /**
     * Get notification message for achievement
     */
    public string get_achievement_notification(CompositeAchievement achievement) {
        var message = new StringBuilder();
        
        if (is_notable_achievement(achievement)) {
            message.append("🏆 ");
        }
        
        message.append(achievement.get_short_description());
        message.append(@" - +$(achievement.score) points!");
        
        if (achievement.score >= best_single_score) {
            message.append(" (New Best!)");
        }
        
        return message.str;
    }
    
    // Signals
    public signal void achievement_recorded(CompositeAchievement achievement);
    public signal void notable_achievement(CompositeAchievement achievement);
}