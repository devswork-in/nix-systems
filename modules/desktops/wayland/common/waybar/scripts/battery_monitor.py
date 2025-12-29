#!/usr/bin/env python3
import subprocess
import json
import math

def get_battery_info():
    try:
        # Use display device for composite stats, or fallback to BAT1
        path = "/org/freedesktop/UPower/devices/battery_BAT1"
        out = subprocess.check_output(["upower", "-i", path]).decode("utf-8")
        
        info = {}
        for line in out.splitlines():
            line = line.strip()
            if ":" in line:
                key, val = line.split(":", 1)
                info[key.strip()] = val.strip()
                
        percent_str = info.get("percentage", "0%").strip("%")
        percent = int(float(percent_str)) if percent_str else 0
        state = info.get("state", "unknown")
        
        # Determine time remaining string
        time_str = ""
        raw_time = ""
        
        if state == "charging":
            raw_time = info.get("time to full", "")
        elif state == "discharging":
            raw_time = info.get("time to empty", "")
            
        # Parse time: upower returns "X.Y hours" or "X minutes"
        # We want "1h 30m" or "30m" (no 0h)
        formatted_time = ""
        
        if raw_time:
            parts = raw_time.split()
            if len(parts) >= 2:
                try:
                    val = float(parts[0])
                    unit = parts[1]
                    
                    hours = 0
                    minutes = 0
                    
                    if "hour" in unit:
                        hours = int(val)
                        minutes = int((val - hours) * 60)
                    elif "minute" in unit:
                        minutes = int(val)
                    
                    # Custom Formatting Logic
                    if hours > 0:
                        formatted_time = f"{hours}h {minutes}m"
                        if minutes == 0:
                             formatted_time = f"{hours}h"
                    elif minutes > 0:
                        formatted_time = f"{minutes}m"
                except:
                    pass
        
        # Icons: Material Design Battery (0% -> 100%)
        icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        # Map 0-100 to 0-9
        idx = min(int(percent / 10), 9)
        
        icon = icons[idx]
        if state == "charging":
             icon = "󰂄" # Charging Bolt
            
        text = f"{icon} {percent}%"
        if formatted_time:
            text += f" ({formatted_time})"
            
        tooltip = f"State: {state}\nClocks: {raw_time}"
        
        return {"text": text, "tooltip": tooltip, "class": state}
        
    except Exception as e:
        return {"text": " Error", "tooltip": str(e)}

print(json.dumps(get_battery_info()))
