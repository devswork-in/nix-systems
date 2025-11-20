# Modules Directory Structure

This directory contains various NixOS modules organized by their purpose and functionality.

## Directory Structure

### Core Modules (Essential system functionality)
- `core/base/` - Base NixOS system configurations (filesystems, basic services)
- `core/core/` - Core system configurations required for any system
- `core/networking/` - Network-related modules (Wireguard, hosts, etc.)
- `core/packages/` - Common packages used by most systems
- `core/configs/common/` - Common configuration files (fish, htop, git, etc.)

### Feature Modules (Domain-specific functionality)
- `desktop/` - Desktop environment configurations
  - `desktop/default.nix` - Complete desktop configuration entry point
  - `desktop/packages/` - Desktop-specific packages
- `server/` - Server configurations
  - `server/default.nix` - Complete server configuration entry point
  - `server/packages/` - Server-specific packages

### Optional Modules
- `apps/` - Application packages and configurations
- `extras/` - Extra configurations and system enhancements
- `services/` - Service-related modules (Steam, VirtManager, Flatpak, Docker, MySQL, etc.)

## Usage

The architecture supports clean, non-redundant configurations:

1. **Server setup**: Import server default module
   ```nix
   imports = [
     ./modules/server/default.nix
   ];
   ```
   *Note: `modules/server/default.nix` automatically imports `modules/core`.*

2. **Desktop setup**: Import desktop default module
   ```nix
   imports = [
     ./modules/desktop/default.nix
   ];
   ```
   *Note: `modules/desktop/default.nix` automatically imports `modules/core`.*

3. **Layering**: Add additional services as needed
   ```nix
   imports = [
     ./modules/desktop/default.nix
     ./modules/services/docker
     ./modules/services/flatpak
   ];
   ```

## Architecture Note

The structure eliminates code duplication by organizing configurations into logical, reusable components:
- Common packages are defined in `core/packages/`
- Server/Desktop packages are in their respective modules
- Clear separation between Core, Desktop, and Server domains

## Adding New Modules

When adding new modules:
1. For core system functionality: Place in appropriate `core/` subdirectory
2. For common packages: Place in `core/packages/`
3. For server-specific features: Place in `server/`
4. For desktop-specific features: Place in `desktop/`
5. For optional apps/services: Place in `apps/` or `services/`
6. Include proper documentation within the module
7. Update the relevant system configurations to use the new module