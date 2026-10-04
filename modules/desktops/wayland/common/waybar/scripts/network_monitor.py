#!/usr/bin/env python3
import time
import json

def get_bytes():
    rx = 0
    tx = 0
    try:
        with open("/proc/net/dev", "r") as f:
            lines = f.readlines()
        for line in lines[2:]:
            parts = line.split()
            if not parts: continue
            ifname = parts[0].strip(":")
            if ifname == "lo" or ifname.startswith("veth") or ifname.startswith("docker"):
                continue
            rx += int(parts[1])
            tx += int(parts[9])
    except:
        pass
    return rx, tx

def format_speed(bytes_per_sec):
    # Strictly formats to exactly 5 characters to completely eliminate jitter
    if bytes_per_sec < 1000:
        return f"{int(bytes_per_sec):>3} B"
    elif bytes_per_sec < 1_000_000:
        val = bytes_per_sec / 1000.0
        if val < 10:
            return f"{val:.2f}K"
        elif val < 100:
            return f"{val:.1f}K"
        else:
            return f"{int(val):>3} K"
    elif bytes_per_sec < 1_000_000_000:
        val = bytes_per_sec / 1_000_000.0
        if val < 10:
            return f"{val:.2f}M"
        elif val < 100:
            return f"{val:.1f}M"
        else:
            return f"{int(val):>3} M"
    else:
        val = bytes_per_sec / 1_000_000_000.0
        if val < 10:
            return f"{val:.2f}G"
        elif val < 100:
            return f"{val:.1f}G"
        else:
            return f"{int(val):>3} G"

def format_speed_tooltip(bytes_per_sec):
    if bytes_per_sec < 1024:
        return f"{bytes_per_sec} B/s"
    elif bytes_per_sec < 1_048_576:
        return f"{bytes_per_sec / 1024.0:.2f} KB/s"
    else:
        return f"{bytes_per_sec / 1_048_576.0:.2f} MB/s"

def main():
    rx_prev, tx_prev = get_bytes()
    print(json.dumps({"text": "   0 B     0 B", "tooltip": "Calculating..."}), flush=True)
    
    while True:
        time.sleep(1)
        rx_now, tx_now = get_bytes()
        
        rx_speed = rx_now - rx_prev
        tx_speed = tx_now - tx_prev
        
        rx_prev = rx_now
        tx_prev = tx_now
        
        rx_str = format_speed(rx_speed)
        tx_str = format_speed(tx_speed)
        
        text = f" {rx_str}   {tx_str}"
        tooltip = f"<b>Network Speed</b>\nDown: {format_speed_tooltip(rx_speed)}\nUp:   {format_speed_tooltip(tx_speed)}"
        
        print(json.dumps({"text": text, "tooltip": tooltip}), flush=True)

if __name__ == "__main__":
    main()
