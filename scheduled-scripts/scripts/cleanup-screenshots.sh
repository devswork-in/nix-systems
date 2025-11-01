#!/usr/bin/env bash
# Cleanup old screenshots

set -euo pipefail

# Get configuration from environment or use defaults
SCREENSHOTS_DIR="${SCREENSHOTS_DIR:-$HOME/Screenshots}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

echo "Cleaning up screenshots older than ${RETENTION_DAYS} days from ${SCREENSHOTS_DIR}"

# Check if directory exists
if [ ! -d "$SCREENSHOTS_DIR" ]; then
    echo "Screenshots directory does not exist: $SCREENSHOTS_DIR"
    exit 0
fi

# Find and delete old screenshots
DELETED_COUNT=$(find "$SCREENSHOTS_DIR" -name "Screenshot_*.png" -type f -mtime "+${RETENTION_DAYS}" -delete -print | wc -l)

echo "Deleted $DELETED_COUNT old screenshot(s)"

# Show current disk usage
echo "Current screenshots directory size:"
du -sh "$SCREENSHOTS_DIR"
