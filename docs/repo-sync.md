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

Run `sysrebuild` from the desired checkout for editable configs. It prefers the
current Git worktree over the cached path and explicitly passes `NIX_CONFIG_DIR`
through sudo. After a successful switch, it updates the `/etc/nixos` symlink and
runs the full sync service, waiting for completion. It refuses to replace a real
`/etc/nixos` directory or file. Failed rebuilds and dry runs do not relink or sync.
A sync failure is reported separately: the system has already switched.

Full sync includes Git updates (including hard resets of managed checkouts) and
post-sync hooks. The weekly timer remains enabled. A raw `nixos-rebuild` command
bypasses this helper workflow; `--impure` alone does not preserve `NIX_CONFIG_DIR`
through sudo.

Walker config and themes live in `modules/desktops/wayland/common/walker`,
synced to `~/.config/walker` on Niri desktops. Run `sysrebuild` from the checkout
to rebuild and sync. To bootstrap before the updated helper is installed, use
`bash modules/core/configs/common/scripts/sysrebuild` from the checkout.
Subsequent file edits need no rebuild or resync: the destination links to the
checkout. A user systemd path unit automatically restarts a running Walker
when its config, CSS, or layouts change; Walker itself has no live config reload.

## Config

- [`sync-config.nix`](../sync-config.nix)
- See [sync-config.nix](../sync-config.nix) for structure

## Commands

```bash
sysrebuild                             # Switch, update /etc/nixos, and sync
nix-repo-sync-force                     # Sync without rebuilding
nix-repo-sync-logs                      # View logs
systemctl status nix-repo-sync.service  # Service status
```
