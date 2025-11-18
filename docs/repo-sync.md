# Nix Repo Sync

Configuration synchronization system using [`nix-repo-sync`](https://github.com/Creator54/nix-repo-sync).

See the [nix-repo-sync README](https://github.com/Creator54/nix-repo-sync/README.md) for installation and usage details.

## This Repository's Configuration

Edit [`sync-config.nix`](../sync-config.nix) to manage sync items:

```nix
{
  common = [ /* synced on all systems */ ];
  desktop = [ /* desktop-only syncs */ ];
  server = [ /* server-only syncs */ ];
}
```

Rebuild with `--impure` flag:
```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
```
