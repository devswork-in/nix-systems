#!/usr/bin/env python3
import json

def get_mem_info():
    try:
        mem_info = {}
        with open('/proc/meminfo') as f:
            for line in f:
                parts = line.split(':')
                if len(parts) == 2:
                    key = parts[0].strip()
                    val = parts[1].strip().split()[0] # Take first part (kb)
                    mem_info[key] = int(val) * 1024 # Convert to bytes

        # RAM Calculations
        mem_total = mem_info.get('MemTotal', 0)
        mem_free = mem_info.get('MemFree', 0)
        mem_buffers = mem_info.get('Buffers', 0)
        mem_cached = mem_info.get('Cached', 0)
        mem_available = mem_info.get('MemAvailable', 0)
        
        # Used = Total - Available (Modern accurate calculation)
        mem_used = mem_total - mem_available
        mem_percent = (mem_used / mem_total) * 100 if mem_total > 0 else 0

        # Swap Calculations
        swap_total = mem_info.get('SwapTotal', 0)
        swap_free = mem_info.get('SwapFree', 0)
        swap_used = swap_total - swap_free
        swap_percent = (swap_used / swap_total) * 100 if swap_total > 0 else 0

        # Formatting Helper (GB = 10^9 bytes)
        def to_gb_val(bytes_val):
            return f"{bytes_val / 1_000_000_000:.1f}"

        def to_gb_str(bytes_val):
             return f"{to_gb_val(bytes_val)}GB"

        # Text: RAM (Used/Total GB)
        text = f"  {to_gb_val(mem_used)}/{to_gb_val(mem_total)} GB"
        
        # Tooltip: Detailed Breakdown
        tooltip = (
            f"<b>RAM</b>\n"
            f"Used: {to_gb_str(mem_used)} ({mem_percent:.1f}%)\n"
            f"Available: {to_gb_str(mem_available)}\n"
            f"Total: {to_gb_str(mem_total)}\n\n"
            f"<b>Swap</b>\n"
            f"Used: {to_gb_str(swap_used)} ({swap_percent:.1f}%)\n"
            f"Total: {to_gb_str(swap_total)}"
        )

        # Percentage for class
        return {"text": text, "tooltip": tooltip, "percentage": int(mem_percent)}

    except Exception as e:
        return {"text": "Error", "tooltip": str(e)}

print(json.dumps(get_mem_info()))
