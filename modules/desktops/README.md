# Desktop Environment Management

This directory contains modular configurations for different desktop environments (DEs) and window managers (WMs).

## Structure

```
desktops/
├── gnome/          # GNOME-based desktop environments
│   ├── base.nix    # Base GNOME configuration
│   ├── vanilla.nix # Vanilla GNOME with extensions
│   └── pop-shell.nix # Pop Shell tiling WM
│
└── wayland/        # Wayland compositors
    ├── shared/     # Shared configs (created when needed)
    └── niri/       # Niri scrollable-tiling compositor
```

## Usage

### Switching Desktop Environments

Edit `profiles/desktop.nix` and change the import:

```nix
{
  imports = [
    ../modules/desktop-utils    # Common desktop utilities
    ../modules/desktops/gnome/pop-shell  # <-- Change this line
    # ../modules/desktops/gnome/vanilla
    # ../modules/desktops/wayland/niri
  ];
}
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Per-System Override

In your system configuration (e.g., `systems/omnix/configuration.nix`):

```nix
{
  imports = [
    ../../profiles/desktop
    # Override with different DE
    ../../modules/desktops/wayland/niri
  ];
}
```

The last import wins, so this overrides the profile's choice.

## Adding a New Desktop Environment

### For a Wayland WM (e.g., Sway)

1. Create directory: `modules/desktops/wayland/sway/`
2. Create `default.nix` with packages and services
3. Create config files (e.g., `config`, `waybar-config.json`)
4. Add to `sync-config.nix` for nix-repo-sync
5. Test by changing import in `profiles/desktop.nix`

### For a Full DE (e.g., KDE)

1. Create directory: `modules/desktops/kde/`
2. Create `default.nix` with KDE setup
3. Add any config files needed
4. Test by changing import in `profiles/desktop.nix`

## Configuration Management

All configuration files (not Nix code) are managed via nix-repo-sync:
- Config files live in the module directory
- nix-repo-sync copies them to `~/.config/`
- Changes sync bidirectionally
- Version controlled in git

Example: niri's `config.kdl`, `waybar-config.json`, etc.

## Shared Modules

Create shared modules only when you have actual duplication:
- See the same 50+ lines in 2+ modules? Extract it.
- Otherwise, keep it inline (YAGNI principle)

Example: `wayland/shared/base.nix` for common Wayland setup when you have 2+ Wayland WMs.

## Rollback

NixOS generations allow easy rollback:
```bash
sudo nixos-rebuild switch --rollback
```

Or select a previous generation from the boot menu.
