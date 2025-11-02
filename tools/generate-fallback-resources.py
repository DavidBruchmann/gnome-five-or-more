#!/usr/bin/env python3
"""
Five or More - Fallback Resource Generation Tool
This script generates fallback resources during the build process.
"""

import os
import sys
import hashlib
import argparse
from pathlib import Path

def compute_checksum(file_path):
    """Compute SHA-256 checksum of a file."""
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def generate_checksum_file(resource_dir, output_file):
    """Generate checksum file for all resources in directory."""
    checksums = {}
    
    for root, dirs, files in os.walk(resource_dir):
        for file in files:
            if file.endswith(('.svg', '.xml', '.ui')):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, resource_dir)
                checksum = compute_checksum(file_path)
                checksums[rel_path] = checksum
    
    with open(output_file, 'w') as f:
        f.write("# Five or More Resource Checksums\n")
        f.write("# Generated automatically - do not edit manually\n\n")
        
        for resource, checksum in sorted(checksums.items()):
            f.write(f"{resource}={checksum}\n")
    
    print(f"Generated checksums for {len(checksums)} resources in {output_file}")

def validate_gresource_file(gresource_file):
    """Validate that GResource file exists and is well-formed."""
    if not os.path.exists(gresource_file):
        print(f"Error: GResource file not found: {gresource_file}")
        return False
    
    try:
        import xml.etree.ElementTree as ET
        tree = ET.parse(gresource_file)
        root = tree.getroot()
        
        if root.tag != 'gresources':
            print(f"Error: Invalid GResource file format: {gresource_file}")
            return False
        
        resource_count = 0
        for gresource in root.findall('gresource'):
            for file_elem in gresource.findall('file'):
                resource_count += 1
                file_path = file_elem.text
                if file_path:
                    # Check if referenced file exists
                    full_path = os.path.join(os.path.dirname(gresource_file), file_path)
                    if not os.path.exists(full_path):
                        print(f"Warning: Referenced file not found: {full_path}")
        
        print(f"GResource validation passed: {resource_count} resources found")
        return True
        
    except Exception as e:
        print(f"Error validating GResource file: {e}")
        return False

def create_fallback_svg():
    """Create a minimal fallback SVG theme."""
    svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="700" version="1.1">
  <defs>
    <style>
      :root {
        --piece-color-0: #FFFF00;
        --piece-color-1: #FF00FF;
        --piece-color-2: #00FF00;
        --piece-color-3: #FF0000;
        --piece-color-4: #0000FF;
        --piece-color-5: #00FFFF;
        --piece-color-6: #FF8000;
        --border-color: #000000;
        --border-width: 2;
      }
      
      .piece {
        stroke: var(--border-color);
        stroke-width: var(--border-width);
        opacity: 1.0;
      }
      
      .piece-0 { fill: var(--piece-color-0); }
      .piece-1 { fill: var(--piece-color-1); }
      .piece-2 { fill: var(--piece-color-2); }
      .piece-3 { fill: var(--piece-color-3); }
      .piece-4 { fill: var(--piece-color-4); }
      .piece-5 { fill: var(--piece-color-5); }
      .piece-6 { fill: var(--piece-color-6); }
    </style>
  </defs>
  
  <g id="theme-sprites">'''
    
    # Generate sprite grid
    for piece_type in range(7):
        y = 50 + (piece_type * 100)
        for anim in range(4):
            x = 50 + (anim * 100)
            radius = 37.5
            if anim == 1:  # shrinking
                radius = 33.75
            elif anim == 2:  # growing
                radius = 41.25
            
            svg_content += f'\n    <circle class="piece piece-{piece_type}" cx="{x}" cy="{y}" r="{radius}"/>'
    
    svg_content += '''
  </g>
</svg>'''
    
    return svg_content

def main():
    parser = argparse.ArgumentParser(description='Generate fallback resources for Five or More')
    parser.add_argument('--data-dir', required=True, help='Data directory path')
    parser.add_argument('--output-dir', required=True, help='Output directory for generated resources')
    parser.add_argument('--gresource-file', help='GResource XML file to validate')
    parser.add_argument('--generate-checksums', action='store_true', help='Generate checksum file')
    
    args = parser.parse_args()
    
    # Create output directory if it doesn't exist
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Validate GResource file if provided
    if args.gresource_file:
        if not validate_gresource_file(args.gresource_file):
            sys.exit(1)
    
    # Generate fallback SVG if template doesn't exist
    template_path = os.path.join(args.data_dir, 'template.svg')
    if not os.path.exists(template_path):
        print(f"Template not found, creating fallback: {template_path}")
        with open(template_path, 'w') as f:
            f.write(create_fallback_svg())
    
    # Generate checksums if requested
    if args.generate_checksums:
        checksum_file = os.path.join(args.output_dir, 'resource-checksums.txt')
        generate_checksum_file(args.data_dir, checksum_file)
    
    print("Fallback resource generation completed successfully")

if __name__ == '__main__':
    main()