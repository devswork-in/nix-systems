#!/usr/bin/env bash
# Diagnostic script to check fusuma status and input device permissions

echo "=== Fusuma Service Status ==="
systemctl --user status fusuma | head -20

echo -e "\n=== Recent Fusuma Logs ==="
journalctl --user -u fusuma --since "2 minutes ago" --no-pager | tail -20

echo -e "\n=== Input Device Permissions ==="
ls -la /dev/input/event* | head -10

echo -e "\n=== User Groups ==="
groups

echo -e "\n=== Fusuma Process ==="
ps aux | grep fusuma | grep -v grep

echo -e "\n=== GNOME Touchpad Settings ==="
gsettings get org.gnome.desktop.peripherals.touchpad tap-to-click
gsettings get org.gnome.desktop.peripherals.touchpad send-events

echo -e "\n=== Active GNOME Extensions ==="
gnome-extensions list --enabled
