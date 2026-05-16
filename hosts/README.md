# Host Configurations

NixOS configurations for machines.

## Hosts

[omnix/](omnix/), [cospi/](cospi/), [server/](server/), [blade/](blade/), [phoenix/](phoenix/)

## Structure

- `configuration.nix` - settings
- `hardware.nix` - hardware
- `fileSystems.nix` - mounts
- Additional files

## Add System

```bash
mkdir -p hosts/newhost/
nixos-generate-config --show-hardware-config > hosts/newhost/hardware.nix
```

Register in [flake.nix](../flake.nix)