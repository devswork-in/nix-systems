# Structure

Repository organization and architecture.

## Directory Layout

```
.
├── lib/                    # Helper functions
│   ├── mkSystemConfig.nix  # System builder
│   └── mkAppImage.nix      # AppImage packager
├── nix-repo-sync/         # Config sync library (standalone flake)
├── profiles/               # Reusable configurations
│   ├── base.nix           # Common settings
│   ├── desktop.nix        # Desktop config
│   └── server.nix         # Server config
├── modules/
│   ├── essential/         # Core modules (base, packages, configs)
│   └── addons/           # Optional modules (desktop, apps, services)
├── systems/              # Machine configs (omnix, blade, cospi, server, phoenix)
├── flake.nix            # Main flake
├── config.nix           # User config
└── sync-config.nix      # Sync config
```

## Components

### lib/

**[`mkSystemConfig.nix`](../lib/mkSystemConfig.nix)** - Creates system configurations

**[`mkAppImage.nix`](../lib/mkAppImage.nix)** - Packages AppImages with desktop integration

### nix-repo-sync/

**[`nix-repo-sync`](../nix-repo-sync/)** - Standalone flake library for configuration synchronization (git repos and symlinks)

### profiles/

**[`base.nix`](../profiles/base.nix)** - Common settings (Nix config, essential packages, user setup, SSH)

**[`desktop.nix`](../profiles/desktop.nix)** - Desktop systems (extends base, adds desktop packages, NetworkManager, boot config)

**[`server.nix`](../profiles/server.nix)** - Server systems (extends base, adds server packages, firewall, web server)

### modules/

**Essential** - Core functionality, included via profiles
- `base/` - System configuration
- `packages/` - Package sets (common, server, desktop)
- `configs/` - Config files (common, server, desktop)

**Addons** - Optional features, explicitly imported
- `desktop/` - Desktop environments
- `apps/` - Applications
- `services/` - Services

### systems/

Machine-specific configurations:
- `configuration.nix` - System settings
- `hardware.nix` - Hardware config
- `fileSystems.nix` - Filesystem mounts

### Configuration Files

**[`config.nix`](../config.nix)** - User settings, service toggles, sync config

**[`sync-config.nix`](../sync-config.nix)** - Dotfile sync (common, desktop, server)

**[`flake.nix`](../flake.nix)** - System definitions, deploy-rs, inputs

## Design

- Profiles eliminate duplication
- Lib functions provide reusable utilities
- Essential modules shared via profiles
- Single-purpose modules with consistent `userConfig` parameter
- No hardcoded paths, portable across systems
