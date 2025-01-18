# Modules Directory Structure

This directory contains various NixOS modules organized by their purpose and functionality.

## Directory Structure

- `configs/` - Configurations, packages, etc.
- `services/` - Service-related modules (Steam, VirtManager, Flatpak, etc.)
- `desktop/` - Desktop environment and UI-related configurations
- `networking/` - Network-related modules (Wireguard, hosts, etc.)
- `website/` - Website-related configurations
- `docker/` - Docker-related configurations
- `local-system/` - System-specific local configurations shared across all systems

## Usage

Each module in these directories can be imported in your system configuration. For example:

```nix
{ config, ... }:
{
  imports = [
    ./modules/services/steam.nix
    ./modules/networking/wireguard.nix
  ];
}
```

## Adding New Modules

When adding new modules:
1. Place them in the appropriate directory based on their purpose
2. Include proper documentation within the module
3. Update the relevant system configurations to use the new module 