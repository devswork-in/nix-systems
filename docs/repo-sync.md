# Repo-Sync

Sync system using [nix-repo-sync](https://github.com/Creator54/nix-repo-sync).

Automatic sync runs weekly, persists missed runs, and has a randomized delay.
Run `nix-repo-sync-force` for immediate synchronization. Sync never rebuilds
NixOS or deploys an application automatically.

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
