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
 * Handles scoring for composite lines
 */
internal class CompositeScoring : Object {
    
    /**
     * Calculate score for a composite line
     */
    public static int calculate_composite_score(CompositeLine composite_line) {
        int base_score = calculate_base_score(composite_line.total_length);
        int bonus_score = composite_line.calculate_bonus_score();
        
        return base_score + bonus_score;
    }
    
    /**
     * Calculate score for traditional line (backward compatibility)
     */
    public static int calculate_traditional_score(int line_length) {
        return calculate_base_score(line_length);
    }
    
    /**
     * Calculate base score using the original formula
     */
    private static int calculate_base_score(int line_length) {
        return (int) (45 * Math.log(0.25 * line_length));
    }
    
    /**
     * Get score description for a composite line
     */
    public static string get_score_description(CompositeLine composite_line, int total_score) {
        if (composite_line.segments.size == 1) {
            return @"$(composite_line.total_length) in a row: $(total_score) points";
        }
        
        var description = new StringBuilder();
        description.append(composite_line.get_pattern_description());
        description.append(@": $(total_score) points");
        
        int bonus = composite_line.calculate_bonus_score();
        if (bonus > 0) {
            description.append(@" (+$(bonus) combo bonus)");
        }
        
        return description.str;
    }
    
    /**
     * Calculate total score for multiple composite lines cleared simultaneously
     */
    public static int calculate_multiple_lines_score(Gee.ArrayList<CompositeLine> composite_lines) {
        int total_score = 0;
        
        foreach (var line in composite_lines) {
            total_score += calculate_composite_score(line);
        }
        
        // Add bonus for multiple lines cleared at once
        if (composite_lines.size > 1) {
            int multiple_lines_bonus = composite_lines.size * 50;
            total_score += multiple_lines_bonus;
        }
        
        return total_score;
    }
    
    /**
     * Get description for multiple lines cleared
     */
    public static string get_multiple_lines_description(Gee.ArrayList<CompositeLine> composite_lines, int total_score) {
        if (composite_lines.size == 1) {
            return get_score_description(composite_lines[0], total_score);
        }
        
        var description = new StringBuilder();
        description.append(@"$(composite_lines.size) lines cleared: $(total_score) points\n");
        
        foreach (var line in composite_lines) {
            int line_score = calculate_composite_score(line);
            description.append("• ");
            description.append(get_score_description(line, line_score));
            description.append("\n");
        }
        
        int bonus = composite_lines.size * 50;
        description.append(@"Multiple lines bonus: +$(bonus) points");
        
        return description.str;
    }
}