# Usage

Building, deploying, and managing systems.

## Local Builds

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
sudo nixos-rebuild test --flake .#<hostname> --impure      # Test without making default
sudo nixos-rebuild build --flake .#<hostname>              # Build only
sudo nixos-rebuild boot --flake .#<hostname> --impure      # Apply on next boot

# From GitHub
sudo nixos-rebuild switch --flake github:creator54/nix-systems#<hostname> --impure
```

### Rollback

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --rollback
```

## Remote Deployment

### SSH Config

Add to `~/.ssh/config`:

```
Host phoenix
    HostName <ip>
    User root
    IdentityFile ~/.ssh/id_rsa
```

### Deploy

```bash
nix run nixpkgs#deploy-rs -- .#phoenix
nix run nixpkgs#deploy-rs -- github:creator54/nix-systems#phoenix
nix run nixpkgs#deploy-rs -- .#server --hostname=phoenix  # Different profile
```

### VM Testing

```bash
nix run nixpkgs#nixos-rebuild -- build-vm --flake .#phoenix --fast
./result/bin/run-*-vm
```

## System Management

### Add New System

```bash
mkdir -p systems/newsystem
```

Create `systems/newsystem/configuration.nix`:

```nix
{ config, pkgs, userConfig, ... }:
{
  imports = [ ./hardware.nix ./fileSystems.nix ];
  networking.hostName = "newsystem";
}
```

Generate hardware config:

```bash
nixos-generate-config --show-hardware-config > systems/newsystem/hardware.nix
```

Add to [`flake.nix`](../flake.nix):

```nix
nixosConfigurations.newsystem = mkSystem {
  system = "x86_64-linux";
  hostname = "newsystem";
  modules = [
    ./systems/newsystem
    ./profiles/desktop.nix
    inputs.home-manager.nixosModules.default
  ];
};
```

Build:

```bash
sudo nixos-rebuild switch --flake .#newsystem --impure
```

### Switch Profiles

Edit [`flake.nix`](../flake.nix):

```nix
modules = [
  ./systems/mysystem
  ./profiles/server.nix  # Changed from desktop.nix
];
```

Rebuild:

```bash
sudo nixos-rebuild switch --flake .#mysystem --impure
```

## Repo-Sync

```bash
repo-sync-force                    # Force sync
repo-sync-logs                     # View logs
systemctl status repo-sync.service # Check status
```

See [`modules/services/repo-sync/`](../modules/services/repo-sync/) for implementation.
