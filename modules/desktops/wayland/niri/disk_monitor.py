#!/usr/bin/env python3
import subprocess
import json
import math

def get_disk_info():
    try:
        # Get disk usage for local filesystems, excluding pseudo-filesystems
        # --block-size=1 returns bytes
        # --output selects columns: target mount point, used, size
        cmd = ["df", "-l", "--block-size=1", "--output=target,used,size", "-x", "tmpfs", "-x", "devtmpfs", "-x", "overlay", "-x", "efivarfs", "-x", "tracefs"]
        output = subprocess.check_output(cmd).decode("utf-8")
        
        lines = output.strip().splitlines()
        # Skip header
        lines = lines[1:]
        
        total_used = 0
        total_size = 0
        mounts_info = []
        
        for line in lines:
            parts = line.split()
            if len(parts) >= 3:
                # Handle mount points with spaces? df output is tricky with spaces.
                # But --output puts target first. If target has spaces, it might break simple split.
                # Safer to assume standard layout or strict mounting.
                # However, usually last two cols are numbers.
                
                try:
                    size = int(parts[-1])
                    used = int(parts[-2])
                    target = " ".join(parts[:-2])
                    
                    # Filter out purely loop devices if desired (snaps usually)
                    # if "/snap/" in target: continue

                    total_used += used
                    total_size += size
                    
                    mounts_info.append({
                        "target": target,
                        "used": used,
                        "size": size
                    })
                except ValueError:
                    continue

        # Helper to convert to GB (Base 10)
        def to_gb_val(bytes_val):
            return f"{bytes_val / 1_000_000_000:.1f}"

        def to_gb_str(bytes_val):
            return f"{to_gb_val(bytes_val)}GB"

        # Find Root usage for Main Text
        root_used = 0
        root_size = 0
        for m in mounts_info:
            if m['target'] == "/":
                root_used = m['used']
                root_size = m['size']
                break
        
        # Fallback if / not found (unlikely) or just use total if preferred, but user asked for Root.
        if root_size == 0 and len(mounts_info) > 0:
             # Fallback to first mount
             root_used = mounts_info[0]['used']
             root_size = mounts_info[0]['size']

        # Text: Root Used / Root Size GB
        text = f"󰋊 {to_gb_val(root_used)}/{to_gb_val(root_size)} GB"
        
        # Tooltip: Breakdown of ALL disks
        tooltip_lines = []
        tooltip_lines.append(f"<b>Root Storage</b>")
        tooltip_lines.append(f"Used: {to_gb_str(root_used)}")
        tooltip_lines.append(f"Total: {to_gb_str(root_size)}")
        tooltip_lines.append("")
        tooltip_lines.append("<b>All Mounts</b>")
        
        for m in mounts_info:
            pct = (m['used'] / m['size'] * 100) if m['size'] > 0 else 0
            tooltip_lines.append(f"{m['target']}: {to_gb_str(m['used'])} / {to_gb_str(m['size'])} ({pct:.0f}%)")
            
        tooltip = "\n".join(tooltip_lines)
        
        # Calculate percentage for progress bar (Based on Root)
        overall_pct = (root_used / root_size * 100) if root_size > 0 else 0
        
        return {"text": text, "tooltip": tooltip, "percentage": int(overall_pct)}

    except Exception as e:
        return {"text": "Error", "tooltip": str(e)}

print(json.dumps(get_disk_info()))
