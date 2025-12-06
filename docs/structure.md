# Structure

Repository architecture.

## Layout

```
.
├── lib/                    # Helper functions
│   ├── mkSystemConfig.nix  # System builder
│   └── mkAppImage.nix      # AppImage packager
├── profiles/               # Reusable configs
│   ├── base.nix           # Common settings
│   ├── desktop.nix        # Desktop config
│   └── server.nix         # Server config
├── modules/
│   ├── addons/            # Addon modules
│   ├── apps/              # App modules
│   ├── core/              # Core modules
│   ├── desktop-utils/     # Desktop configs
│   ├── desktops/          # Desktop envs
│   ├── server/            # Server configs
│   ├── services/          # Service modules
│   └── extras/            # Additional modules
├── scheduled-scripts/   # Scheduled scripts
├── systems/             # Machine configs
├── flake.nix            # Main flake
├── config.nix           # User config
└── sync-config.nix      # Sync config
```

## Components

### lib/

[`mkSystemConfig.nix`](../lib/mkSystemConfig.nix), [`mkAppImage.nix`](../lib/mkAppImage.nix)

### profiles/

[`base.nix`](../profiles/base.nix), [`desktop.nix`](../profiles/desktop.nix), [`server.nix`](../profiles/server.nix)

### modules/

**Core**: `core/base/`, `core/packages/`, `core/configs/`, `core/networking/`, `core/command-scheduler/`

**Desktop**: `desktop-utils/`, `desktops/` (gnome, pantheon, wayland)

**Apps**: `apps/` (appimages, kiro)

**Services**: `services/` (docker, flatpak, mysql, snaps, steam, etc.)

**Server**: `server/`

**Extras**: `extras/`

### systems/

- `configuration.nix` - system settings
- `hardware.nix` - hardware config
- `fileSystems.nix` - mounts
- Additional files (hibernation.nix, ollama.nix, etc.)

### Config Files

[`config.nix`](../config.nix), [`sync-config.nix`](../sync-config.nix), [`flake.nix`](../flake.nix)

## Design

- Profiles eliminate duplication
- Lib functions provide reusable utilities
- Modules have consistent structure
- Portable across systems
