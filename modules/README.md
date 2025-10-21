# Modules Directory Structure

This directory contains various NixOS modules organized by their purpose and functionality.

## Directory Structure

### Essential Modules (Core system functionality)
- `essential/base/` - Base NixOS system configurations (filesystems, basic services)
- `essential/core/` - Core system configurations required for any system
- `essential/networking/` - Network-related modules (Wireguard, hosts, etc.)
- `essential/packages/common/` - Common packages used by most systems
- `essential/packages/server/` - Server-specific packages
- `essential/packages/desktop/` - Desktop-specific packages that extend common
- `essential/configs/common/` - Common configuration files (fish, htop, git, etc.)
- `essential/configs/server/` - Server-specific configurations
- `essential/configs/desktop/` - Desktop-specific configurations
- `essential/server-config.nix` - Complete server home-manager configuration (common packages/configs + server packages/configs)

### Common Modules (Shared configurations)
- `common/` - Common system-level configurations used across modules

### Addon Modules (Optional functionality)
- `addons/apps/` - Application packages and configurations
- `addons/desktop/` - Desktop environment configurations
  - `addons/desktop/desktop-config.nix` - Complete desktop home-manager configuration (common packages/configs + desktop packages/configs)
- `addons/extras/` - Extra configurations and system enhancements
- `addons/services/` - Service-related modules (Steam, VirtManager, Flatpak, Docker, MySQL, etc.)

## Usage

The architecture supports clean, non-redundant configurations:
1. **Server setup**: Import essential system configs + server home-manager config
   ```nix
   imports = [
     ./modules/essential/core
     ./modules/essential/networking
     ./modules/essential/server-config.nix
   ];
   ```

2. **Desktop setup**: Import essential system configs + desktop home-manager config
   ```nix
   imports = [
     ./modules/essential/core
     ./modules/essential/networking
     ./modules/addons/desktop/desktop-config.nix
   ];
   ```

3. **Layering**: Add additional addon services as needed
   ```nix
   imports = [
     ./modules/essential/core
     ./modules/essential/networking
     ./modules/addons/desktop/desktop-config.nix
     ./modules/addons/services/docker
     ./modules/addons/services/flatpak
   ];
   ```

## Architecture Note

The structure eliminates code duplication by organizing configurations into logical, reusable components:
- Common packages are defined once in `essential/packages/common/`
- Server packages extend common packages
- Desktop packages extend common packages
- No redundant "minimal vs full" structure - just essential vs addons

## Adding New Modules

When adding new modules:
1. For core system functionality: Place in appropriate essential/ subdirectory
2. For common packages across systems: Place in `essential/packages/common/`
3. For server-specific packages: Place in `essential/packages/server/`
4. For desktop-specific packages: Place in `essential/packages/desktop/`
5. For optional functionality: Place in appropriate addons/ subdirectory
6. Include proper documentation within the module
7. Update the relevant system configurations to use the new module 