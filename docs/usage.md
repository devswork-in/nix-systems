# Usage

Build, deploy, and manage systems.

## Builds

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure  # Build & switch
sudo nixos-rebuild test --flake .#<hostname> --impure    # Test only
sudo nixos-rebuild build --flake .#<hostname>            # Build only
sudo nixos-rebuild boot --flake .#<hostname> --impure    # Next boot

# From GitHub
sudo nixos-rebuild switch --flake github:devswork-in/nix-systems#<hostname> --impure
```

### Rollback

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --rollback
```

## Deploy

### SSH Config

Add to `~/.ssh/config`:

```
Host phoenix
    HostName <ip>
    User root
    IdentityFile ~/.ssh/id_rsa
```

### Remote

```bash
nix run nixpkgs#deploy-rs -- .#phoenix
nix run nixpkgs#deploy-rs -- github:devswork-in/nix-systems#phoenix
nix run nixpkgs#deploy-rs -- .#server --hostname=phoenix
```

### VM Test

```bash
nix run nixpkgs#nixos-rebuild -- build-vm --flake .#phoenix --fast
./result/bin/run-*-vm
```

## Systems

### New System

```bash
mkdir -p systems/newsystem
nixos-generate-config --show-hardware-config > systems/newsystem/hardware.nix
```

- See [systems/omnix/configuration.nix](../systems/omnix/configuration.nix) for structure
- Add to [`flake.nix`](../flake.nix), see [flake.nix](../flake.nix) for patterns

```bash
sudo nixos-rebuild switch --flake .#newsystem --impure
```

### Switch Profile

- Edit [`flake.nix`](../flake.nix) (desktop.nix, server.nix)
- See [flake.nix](../flake.nix) for usage

```bash
sudo nixos-rebuild switch --flake .#mysystem --impure
```

## Sync

```bash
nix-repo-sync-force                # Force sync
nix-repo-sync-logs                 # View logs
systemctl status nix-repo-sync.service # Status
```
