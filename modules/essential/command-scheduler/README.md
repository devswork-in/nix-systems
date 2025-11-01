# Command Scheduler Module

Technical documentation for the command scheduler implementation.

## Overview

This module reads scheduled command configurations from `~/.config/scheduled-scripts/scheduled-commands.nix` and automatically generates systemd services and timers. It supports both user-level and system-level execution with comprehensive logging.

### Hot-Reload Feature

The module includes automatic hot-reload functionality using systemd path units:

- **Watches**: `~/.config/scheduled-scripts/scheduled-commands.nix`
- **Triggers**: `nixos-rebuild switch` when file changes
- **Automatic**: No manual intervention needed
- **Background**: Rebuild runs in background, doesn't block

This allows you to edit the configuration and have changes applied automatically within ~30 seconds.

## Architecture

### System Type Detection

The module automatically detects whether it's running on a desktop or server system by checking for the existence of `desktop-config.nix`. Based on this:

- **Desktop systems**: Execute commands from `common` and `desktop` blocks
- **Server systems**: Execute commands from `common` and `server` blocks

### Service Generation

For each enabled command, the module generates:

1. **Wrapper Script**: Shell script with logging that executes the command
2. **Systemd Service**: Oneshot service that runs the wrapper script
3. **Systemd Timer**: Timer that triggers the service based on schedule

### Execution Levels

- **User-level** (`level = "user"`): Creates `systemd.user.services` and `systemd.user.timers`
- **System-level** (`level = "system"`): Creates `systemd.services` and `systemd.timers` (runs as root)

## Log Format

All command executions produce structured logs:

```
[SCHEDULED-COMMAND] START: 2025-11-01T14:30:45+00:00
[SCHEDULED-COMMAND] NAME: command-name
[SCHEDULED-COMMAND] USER: username
[SCHEDULED-COMMAND] LEVEL: user|system
[SCHEDULED-COMMAND] WORKING_DIR: /path/to/dir
[SCHEDULED-COMMAND] COMMAND: actual command
[SCHEDULED-COMMAND] OUTPUT: command output
[SCHEDULED-COMMAND] EXIT_CODE: 0
[SCHEDULED-COMMAND] END: 2025-11-01T14:30:45+00:00
[SCHEDULED-COMMAND] DURATION: 0s
```

## Viewing Logs

### User-level Services

```bash
# List all user timers
systemctl --user list-timers

# View specific service logs
journalctl --user -u scheduled-<command-name>.service

# View all scheduled command logs
journalctl --user | grep "\[SCHEDULED-COMMAND\]"

# Filter by command name
journalctl --user | grep "NAME: command-name"

# Follow logs in real-time
journalctl --user -u scheduled-<command-name>.service -f
```

### System-level Services

```bash
# List all system timers
sudo systemctl list-timers

# View specific service logs
sudo journalctl -u scheduled-<command-name>.service

# View all scheduled command logs
sudo journalctl | grep "\[SCHEDULED-COMMAND\]"
```

## Managing Services

### Manually Trigger a Command

User-level:
```bash
systemctl --user start scheduled-<command-name>.service
```

System-level:
```bash
sudo systemctl start scheduled-<command-name>.service
```

### Check Service Status

User-level:
```bash
systemctl --user status scheduled-<command-name>.service
```

System-level:
```bash
sudo systemctl status scheduled-<command-name>.service
```

### Check Timer Status

User-level:
```bash
systemctl --user status scheduled-<command-name>.timer
```

System-level:
```bash
sudo systemctl status scheduled-<command-name>.timer
```

### Enable/Disable Timers

Timers are automatically enabled/disabled based on the `enabled` field in the configuration. To temporarily disable without editing config:

User-level:
```bash
systemctl --user stop scheduled-<command-name>.timer
systemctl --user disable scheduled-<command-name>.timer
```

System-level:
```bash
sudo systemctl stop scheduled-<command-name>.timer
sudo systemctl disable scheduled-<command-name>.timer
```

## Hot-Reload Management

### Check Hot-Reload Status

```bash
# Check if watcher is active
systemctl --user status scheduled-commands-watcher.path

# View reload logs
journalctl --user -u scheduled-commands-reload.service

# Follow reload logs in real-time
journalctl --user -u scheduled-commands-reload.service -f
```

### Manually Trigger Reload

```bash
systemctl --user start scheduled-commands-reload.service
```

### Disable/Enable Hot-Reload

```bash
# Disable
systemctl --user stop scheduled-commands-watcher.path
systemctl --user disable scheduled-commands-watcher.path

# Enable
systemctl --user enable scheduled-commands-watcher.path
systemctl --user start scheduled-commands-watcher.path
```

## Troubleshooting

### Hot-Reload Not Working

1. Check if watcher is running:
   ```bash
   systemctl --user status scheduled-commands-watcher.path
   ```

2. Check reload service logs:
   ```bash
   journalctl --user -u scheduled-commands-reload.service -n 50
   ```

3. Verify sudo permissions:
   ```bash
   sudo -l | grep nixos-rebuild
   ```
   Should show: `NOPASSWD: /nix/store/.../nixos-rebuild`

4. Manually trigger to test:
   ```bash
   systemctl --user start scheduled-commands-reload.service
   ```

### Command Not Running

1. Check if timer is active:
   ```bash
   systemctl --user list-timers | grep scheduled-<command-name>
   ```

2. Check service status:
   ```bash
   systemctl --user status scheduled-<command-name>.service
   ```

3. View recent logs:
   ```bash
   journalctl --user -u scheduled-<command-name>.service -n 50
   ```

### Command Failing

1. Check exit code in logs:
   ```bash
   journalctl --user -u scheduled-<command-name>.service | grep "EXIT_CODE"
   ```

2. Check command output:
   ```bash
   journalctl --user -u scheduled-<command-name>.service | grep "OUTPUT"
   ```

3. Manually run the command to test:
   ```bash
   systemctl --user start scheduled-<command-name>.service
   journalctl --user -u scheduled-<command-name>.service -f
   ```

### Path Issues

- Ensure `~` is used for home directory paths in configuration
- The module automatically expands `~` to the appropriate home directory
- For system-level commands, `~` expands to `/root`
- For user-level commands, `~` expands to `/home/username`

### Permission Issues

- User-level commands run as the logged-in user
- System-level commands run as root
- Ensure the `level` field is set correctly based on required permissions

### Timer Not Triggering

1. Check timer configuration:
   ```bash
   systemctl --user cat scheduled-<command-name>.timer
   ```

2. Check next trigger time:
   ```bash
   systemctl --user list-timers | grep scheduled-<command-name>
   ```

3. Verify schedule expression syntax in configuration

## Implementation Details

### Path Expansion

The module expands `~` in paths using:
```nix
expandPath = path: 
  if lib.hasPrefix "~/" path 
  then "${homeDir}/${lib.removePrefix "~/" path}"
  else path;
```

### Command Execution

Commands are executed in a wrapper script that:
1. Sets up logging
2. Exports environment variables
3. Changes to working directory
4. Executes the command
5. Captures output and exit code
6. Logs all details

### Script File Support

When `script` is specified instead of `command`, the module uses the script file path directly. Script files should:
- Be executable (`chmod +x`)
- Have proper shebang (`#!/usr/bin/env bash`)
- Handle errors appropriately

## Configuration Reference

See `~/.config/scheduled-scripts/README.md` for configuration documentation.
