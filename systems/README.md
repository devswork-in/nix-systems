# System Configurations

NixOS configurations for machines.

## Systems

[omnix/](omnix/), [cospi/](cospi/), [server/](server/), [blade/](blade/), [phoenix/](phoenix/)

## Structure

- `configuration.nix` - settings
- `hardware.nix` - hardware
- `fileSystems.nix` - mounts
- Additional files

## Add System

```bash
mkdir -p systems/newsystem/
nixos-generate-config --show-hardware-config > systems/newsystem/hardware.nix
```

Register in [flake.nix](../flake.nix)