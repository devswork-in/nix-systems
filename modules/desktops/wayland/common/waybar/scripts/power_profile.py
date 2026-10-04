#!/usr/bin/env python3
import sys
import subprocess
import json
import os

PROFILE_FILE = "/sys/firmware/acpi/platform_profile"
CHOICES_FILE = "/sys/firmware/acpi/platform_profile_choices"

ICONS = {
    "low-power": "",
    "balanced": "",
    "performance": ""
}

def get_current_profile():
    try:
        with open(PROFILE_FILE, "r") as f:
            return f.read().strip()
    except Exception:
        return "balanced"

def get_choices():
    try:
        with open(CHOICES_FILE, "r") as f:
            return f.read().strip().split()
    except Exception:
        return ["low-power", "balanced", "performance"]

def show_menu():
    choices = get_choices()
    current = get_current_profile()
    
    menu_input = "\n".join(choices)
    
    try:
        result = subprocess.run(
            ["walker", "-d"],
            input=menu_input,
            text=True,
            capture_output=True
        )
        selected = result.stdout.strip()
        if selected in choices and selected != current:
            subprocess.run(
                ["sudo", "/run/current-system/sw/bin/tee", PROFILE_FILE],
                input=selected + "\n",
                text=True,
                capture_output=True
            )
            # Signal waybar to redraw
            subprocess.run(["pkill", "-RTMIN+6", "waybar"])
    except Exception as e:
        pass

def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--menu":
        show_menu()
        return

    current = get_current_profile()
    icon = ICONS.get(current, "")
    choices = get_choices()
    
    tooltip_lines = [f"<b>Power Profile:</b> {current}"]
    tooltip_lines.append("")
    tooltip_lines.append("<b>Available Modes:</b>")
    for c in choices:
        mark = " (Active)" if c == current else ""
        tooltip_lines.append(f"- {c}{mark}")
    
    print(json.dumps({
        "text": icon,
        "tooltip": "\n".join(tooltip_lines),
        "class": current
    }))

if __name__ == "__main__":
    main()
