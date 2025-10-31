# Sync

Configuration synchronization system.

## Overview

Manages dotfiles and configurations via git repositories and symlinks. Impure but allows flexibility of having things outside /nix/store without rewriting everything in Nix.

Implementation: [`modules/services/repo-sync/`](../modules/services/repo-sync/), [`lib/mkRepoSync.nix`](../lib/mkRepoSync.nix)

**Runs:**
- On system activation
- Hourly via systemd timer
- On demand via `repo-sync-force`

**Sync Types:**
- **Git** - One-way (clone/pull from remote)
- **Local** - Bi-directional (symlinks, edit anywhere)

## Configuration

Edit [`sync-config.nix`](../sync-config.nix):

```nix
{
  # All systems
  common = [
    { type = "git"; url = "https://github.com/user/nvim"; dest = "~/.config/nvim"; }
    { type = "local"; source = "${nixSystemsRoot}/configs/fish"; dest = "~/.config/fish"; }
  ];
  
  # Desktop only
  desktop = [
    { type = "local"; source = "${nixSystemsRoot}/configs/kitty.conf"; dest = "~/.config/kitty/kitty.conf"; }
  ];
  
  # Server only
  server = [
    { type = "git"; url = "https://github.com/user/site"; dest = "/var/www/site"; }
  ];
}
```

## Adding Items

1. Edit [`sync-config.nix`](../sync-config.nix)
2. Rebuild: `sudo nixos-rebuild switch --flake .#<hostname> --impure`
3. Verify: `repo-sync-logs | tail -20`

## CLI

```bash
repo-sync-force         # Force sync now
repo-sync-logs          # View logs (last 100 lines)
repo-sync-logs 50       # View logs (last 50 lines)

systemctl status repo-sync.service
systemctl status repo-sync.timer
```

Log location: `/var/log/repo-sync.log`
