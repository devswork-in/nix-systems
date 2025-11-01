# Scheduled Scripts Configuration

This directory contains scheduled command configurations that are synced to `~/.config/scheduled-scripts/` for easy editing.

## Structure

- `default.nix` - Entry point that imports all configuration
- `scheduled-commands.nix` - Command definitions organized by system type
- `scripts/` - Directory for external script files

## Configuration Blocks

Commands are organized into three blocks:

- **common** - Commands that run on all systems (desktop and server)
- **desktop** - Commands that only run on desktop systems
- **server** - Commands that only run on server systems

## Command Definition

Each command has the following structure:

```nix
{
  name = "unique-command-name";           # Unique identifier
  description = "Human readable description";
  command = "shell command";              # OR
  script = ./scripts/script-file.sh;      # Path to external script
  schedule = {
    onCalendar = "daily";                 # Cron-like schedule
    # OR
    onBootSec = "5min";                   # Time after boot
    onUnitActiveSec = "1h";               # Time after last run
  };
  level = "user";                         # "user" or "system" (root)
  enabled = true;                         # Enable/disable
  workingDirectory = "~";                 # Working directory
  environment = {                         # Environment variables
    VAR_NAME = "value";
  };
}
```

## Schedule Expressions

### OnCalendar (Cron-like)
- `hourly` - Every hour
- `daily` - Every day at midnight
- `weekly` - Every Monday at midnight
- `monthly` - First day of month
- `Mon,Wed,Fri 14:00` - Specific days and times
- `*-*-* 00/2:00` - Every 2 hours

### OnBootSec (After Boot)
- `1min`, `5min`, `1h`, `30s`

### OnUnitActiveSec (After Last Run)
- `30min`, `1h`, `6h`, `1d`

## Managing Scheduled Commands

### View Active Timers

User-level timers:
```bash
systemctl --user list-timers
```

System-level timers:
```bash
sudo systemctl list-timers
```

### Manually Trigger a Command

User-level:
```bash
systemctl --user start scheduled-<command-name>.service
```

System-level:
```bash
sudo systemctl start scheduled-<command-name>.service
```

### View Logs

User-level:
```bash
journalctl --user -u scheduled-<command-name>.service
```

System-level:
```bash
sudo journalctl -u scheduled-<command-name>.service
```

### Filter Logs by Command

```bash
journalctl --user | grep "\[SCHEDULED-COMMAND\]"
journalctl --user | grep "NAME: <command-name>"
```

## Editing Configuration

### Automatic Hot-Reload (Recommended)

The system automatically watches `~/.config/scheduled-scripts/scheduled-commands.nix` for changes:

1. Edit `~/.config/scheduled-scripts/scheduled-commands.nix`
2. Save the file
3. **Automatic rebuild triggers in background** (takes ~30 seconds)
4. Check timer status with `systemctl --user list-timers`

You'll see reload logs with:
```bash
journalctl --user -u scheduled-commands-reload.service -f
```

### Manual Rebuild

If you prefer manual control or want to rebuild immediately:

1. Edit files in `~/.config/scheduled-scripts/`
2. Run `nixos-rebuild switch` to apply changes
3. Check timer status with `systemctl --user list-timers`

### Disable Hot-Reload

To disable automatic reloading:
```bash
systemctl --user stop scheduled-commands-watcher.path
systemctl --user disable scheduled-commands-watcher.path
```

## Examples

See `scheduled-commands.nix` for example configurations including:
- System health checks
- Directory maintenance
- Cleanup tasks
- Backup operations
