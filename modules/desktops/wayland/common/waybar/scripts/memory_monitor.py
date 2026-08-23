#!/usr/bin/env python3
import json
import os
from pathlib import Path

# Kernel/interpreter thread names that hide the real program
GENERIC_NAMES = {'MainThread', 'node', 'python3', 'npm', 'npm exec chrome'}
# Script basenames too generic to display; use the parent dir (package) instead
GENERIC_SCRIPTS = {'main', 'index', 'server', 'cli', 'watchdog', '__main__'}

def readable_name(name, cmdline):
    tokens = [t for t in cmdline.split('\0') if t]
    if not tokens:
        return name
    raw = ' '.join(tokens)
    # "npm exec <pkg>..." where the whole command may be a single argv string
    if 'npm exec' in raw:
        pkg = raw.split('npm exec', 1)[1].split()[0]
        return pkg.rsplit('@', 1)[0] if not pkg.startswith('@') else pkg
    exe = os.path.basename(tokens[0])
    if name in GENERIC_NAMES or exe in ('node', 'python3'):
        for t in tokens[1:]:
            if t.startswith('-'):
                continue
            base = os.path.basename(t)
            stem = base.rsplit('.', 1)[0]
            if stem in GENERIC_SCRIPTS:
                parts = os.path.normpath(t).split('/')
                if 'node_modules' in parts:
                    return parts[parts.index('node_modules') + 1]
                return os.path.basename(os.path.dirname(t))
            return stem
    return name

def get_top_processes(count=5):
    # Aggregate RSS per process name across all PIDs
    rss_by_name = {}
    for proc in Path('/proc').iterdir():
        if not proc.name.isdigit():
            continue
        try:
            name = None
            rss = 0
            with open(proc / 'status') as f:
                for line in f:
                    if line.startswith('Name:'):
                        name = line.split(':', 1)[1].strip()
                    elif line.startswith('VmRSS:'):
                        rss = int(line.split()[1]) * 1024
                        break
            if name and rss > 0:
                try:
                    cmdline = open(proc / 'cmdline').read()
                except OSError:
                    cmdline = ''
                label = readable_name(name, cmdline)
                rss_by_name[label] = rss_by_name.get(label, 0) + rss
        except (OSError, ValueError, IndexError):
            continue
    return sorted(rss_by_name.items(), key=lambda x: x[1], reverse=True)[:count]

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

        # Top processes (shared by bar + tooltip)
        top = get_top_processes(5)

        # Text: RAM used/total + live top-3 (bar redraws every interval)
        top_bar = " · ".join(f"{n} {to_gb_val(rss)}G" for n, rss in top[:3])
        text = f"  {to_gb_val(mem_used)}/{to_gb_val(mem_total)} GB · {top_bar}"

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

        # Top processes section
        if top:
            lines = [f"{name:<16}{to_gb_str(rss):>8}" for name, rss in top]
            tooltip += "\n\n<b>Top Processes</b>\n<tt>" + "\n".join(lines) + "</tt>"

        # Percentage for class
        return {"text": text, "tooltip": tooltip, "percentage": int(mem_percent)}

    except Exception as e:
        return {"text": "Error", "tooltip": str(e)}

print(json.dumps(get_mem_info()))
