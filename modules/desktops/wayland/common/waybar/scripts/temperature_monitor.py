#!/usr/bin/env python3
import glob
import html
import json
import os

def get_temp_info():
    try:
        readings = []
        for hwmon in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
            name = "unknown"
            name_file = os.path.join(hwmon, "name")
            if os.path.exists(name_file):
                try:
                    with open(name_file) as f:
                        name = f.read().strip()
                except Exception:
                    pass

            for temp_input in sorted(glob.glob(os.path.join(hwmon, "temp*_input"))):
                base = temp_input[:-6]
                label_file = base + "_label"
                label = ""
                if os.path.exists(label_file):
                    try:
                        with open(label_file) as f:
                            label = f.read().strip()
                    except Exception:
                        pass

                try:
                    with open(temp_input) as f:
                        val = int(f.read().strip())
                    readings.append({
                        "driver": name,
                        "label": label,
                        "temp": val / 1000.0,
                    })
                except Exception:
                    continue

        cpu_readings = []
        gpu_readings = []
        storage_readings = []
        net_readings = []
        board_readings = []
        other_readings = []

        primary_cpu_temp = None

        for r in readings:
            drv = r["driver"].lower()
            lbl = r["label"]
            temp = r["temp"]

            if any(k in drv for k in ("k10temp", "coretemp", "zenpower", "cpu")):
                cpu_readings.append(r)
                if primary_cpu_temp is None or "tctl" in lbl.lower() or "package" in lbl.lower():
                    primary_cpu_temp = temp
            elif any(k in drv for k in ("amdgpu", "nouveau", "nvidia")):
                gpu_readings.append(r)
            elif "nvme" in drv:
                storage_readings.append(r)
            elif any(k in drv for k in ("phy", "wifi", "iwlwifi")):
                net_readings.append(r)
            elif "acpitz" in drv:
                board_readings.append(r)
            else:
                other_readings.append(r)

        if primary_cpu_temp is None:
            if cpu_readings:
                primary_cpu_temp = cpu_readings[0]["temp"]
            elif board_readings:
                primary_cpu_temp = board_readings[0]["temp"]
            elif readings:
                primary_cpu_temp = readings[0]["temp"]
            else:
                primary_cpu_temp = 0.0

        int_temp = int(round(primary_cpu_temp))
        if int_temp >= 80:
            icon = ""
            css_class = "critical"
        elif int_temp >= 70:
            icon = ""
            css_class = "warning"
        else:
            icon = ""
            css_class = "normal"

        text = f"{icon} {int_temp}°C"

        def fmt_row(name, val):
            name_esc = html.escape(name)
            return f"{name_esc:<20} {val:>5.1f}°C"

        sections = []

        if cpu_readings:
            rows = [fmt_row(r["label"] if r["label"] else r["driver"], r["temp"]) for r in cpu_readings]
            sections.append("<b>CPU</b>\n<tt>" + "\n".join(rows) + "</tt>")

        if gpu_readings:
            rows = []
            for r in gpu_readings:
                disp = f"{r['driver']} ({r['label']})" if r["label"] else r["driver"]
                rows.append(fmt_row(disp, r["temp"]))
            sections.append("<b>GPU</b>\n<tt>" + "\n".join(rows) + "</tt>")

        sys_net = []
        for r in board_readings:
            disp = "Motherboard (ACPI)" if "acpitz" in r["driver"] else r["driver"]
            sys_net.append(fmt_row(disp, r["temp"]))
        for r in net_readings:
            disp = "Wi-Fi" if ("phy" in r["driver"] or "wifi" in r["driver"]) else r["driver"]
            sys_net.append(fmt_row(disp, r["temp"]))
        if sys_net:
            sections.append("<b>System &amp; Network</b>\n<tt>" + "\n".join(sys_net) + "</tt>")

        if storage_readings:
            rows = [fmt_row(r["label"] if r["label"] else r["driver"], r["temp"]) for r in storage_readings]
            sections.append("<b>Storage (NVMe)</b>\n<tt>" + "\n".join(rows) + "</tt>")

        if other_readings:
            rows = []
            for r in other_readings:
                disp = f"{r['driver']} {r['label']}".strip()
                rows.append(fmt_row(disp, r["temp"]))
            sections.append("<b>Other</b>\n<tt>" + "\n".join(rows) + "</tt>")

        tooltip = "\n\n".join(sections)

        return {
            "text": text,
            "tooltip": tooltip,
            "percentage": int_temp,
            "class": css_class
        }
    except Exception as e:
        return {"text": " N/A", "tooltip": str(e), "class": "normal"}

if __name__ == "__main__":
    print(json.dumps(get_temp_info()))
