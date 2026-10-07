# Repo-Sync

Sync system using [nix-repo-sync](https://github.com/Creator54/nix-repo-sync).

Automatic sync runs weekly, persists missed runs, and has a randomized delay.
Run `nix-repo-sync-force` for immediate synchronization. Sync never rebuilds
NixOS or deploys an application automatically.

`~/.local/bin` must remain a writable user directory. Sync owns only the
individual helpers listed in `sync-config.nix`; installers own other commands
(including AGY and its profile launchers). Add new tracked helpers to that list.
Never sync the whole directory: Git-ignored tools are absent from flake store
snapshots. When migrating an existing directory symlink, stop the old sync
timer first, back up the symlink, and restore local tools without overwriting
conflicts before activating the new configuration.

For editable configs, explicitly pass `NIX_CONFIG_DIR` pointing to the current
checkout when rebuilding. `/etc/nixos` may point to an older checkout.

Walker config and themes live in `modules/desktops/wayland/common/walker`,
synced to `~/.config/walker` on Niri desktops. Use the current checkout for
the initial rebuild (`NIX_CONFIG_DIR="$PWD"`), then run `nix-repo-sync-force`.
Subsequent file edits need no rebuild or resync: the destination links to the
checkout. A user systemd path unit automatically restarts a running Walker
when its config, CSS, or layouts change; Walker itself has no live config reload.

## Config

- [`sync-config.nix`](../sync-config.nix)
- See [sync-config.nix](../sync-config.nix) for structure

## Commands

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure  # Rebuild with --impure flag
nix-repo-sync-force                                     # Force sync
nix-repo-sync-logs                                      # View logs
systemctl status nix-repo-sync.service                  # Service status
```
