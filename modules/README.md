# Modules Directory Structure

This directory contains various NixOS modules organized by their purpose and functionality.

## Directory Structure

### Core Modules (Essential system functionality)
- `core/base/` - Base NixOS system configurations (filesystems, basic services)
- `core/packages/` - Common packages used by most systems
- `core/configs/` - Common configuration files (fish, htop, git, etc.)
- `core/networking/` - Network-related modules
- `core/command-scheduler/` - System command scheduling

### Desktop Modules (Desktop-specific functionality)
- `desktop-utils/` - Desktop utilities and configurations (bluetooth, gtk-config, performance-optimization, etc.)
- `desktops/` - Desktop environment modules (gnome, pantheon, wayland)

### Server Modules (Server-specific functionality)
- `server/` - Server configurations

### Service Modules (System services)
- `services/` - Service-related modules (Docker, Flatpak, MySQL, Snaps, Steam, VirtManager, etc.)

### Application Modules (Application packages)
- `apps/` - Application packages and configurations (appimages, kiro)

### Extra Modules
- `extras/` - Additional configurations and system enhancements

## Usage

The architecture supports clean, non-redundant configurations:

1. **Server setup**: Import server modules
   ```nix
   imports = [
     ./modules/server/default.nix
   ];
   ```

2. **Desktop setup**: Import desktop modules
   ```nix
   imports = [
     ./modules/desktop-utils/default.nix
   ];
   ```

3. **Layering**: Add additional services as needed
   ```nix
   imports = [
     ./modules/desktop-utils/default.nix
     ./modules/services/docker
     ./modules/services/flatpak
   ];
   ```

## Architecture Note

The structure eliminates code duplication by organizing configurations into logical, reusable components:
- Common packages are defined in `core/packages/`
- Desktop utilities in `desktop-utils/`
- Services in `services/`
- Clear separation between different domain configurations

## Adding New Modules

When adding new modules:
1. For core system functionality: Place in appropriate `core/` subdirectory
2. For desktop utilities: Place in `desktop-utils/`
3. For desktop environments: Place in `desktops/`
4. For server-specific features: Place in `server/`
5. For services: Place in `services/`
6. For applications: Place in `apps/`
7. For extras: Place in `extras/`
8. Include proper documentation within the module
9. Update the relevant system configurations to use the new module