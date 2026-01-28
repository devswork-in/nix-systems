# Modules

System modules and services.

## Core

Core functionality. See [`modules/core/`](../modules/core/).

- `base/` - System configs
- `packages/` - Package sets
- `configs/` - Config files
- `networking/` - Network configs
- `command-scheduler/` - Command scheduling

## Desktop

Desktop configurations. See [`modules/desktop-utils/`](../modules/desktop-utils/).

### Utilities

- `bluetooth.nix`, `gtk-config.nix`, `performance-optimization.nix`, `plymouth.nix`, `nightlight.nix`, `tlp.nix`
- Configs: `kitty.conf`, `gromit-mpx.ini`, `flameshot/flameshot.ini`

### Environments

- `modules/desktops/gnome/`, `modules/desktops/pantheon/`, `modules/desktops/wayland/`

## Apps

Application packages. See [`modules/apps/`](../modules/apps/).

- AppImages: [zen-browser.nix](../modules/apps/appimages/zen-browser.nix), [obsidian.nix](../modules/apps/appimages/obsidian.nix)
- `modules/apps/kiro/` - Kiro apps

## Services

System services. See [`modules/services/`](../modules/services/).

### Package Management

- `docker/`, `flatpak.nix`, `snaps.nix`

### Web Services

- Configure in [`config.nix`](../config.nix)
- See [`modules/services/website/`](../modules/services/website/)
- Examples: [next-cloud.nix](../modules/services/website/next-cloud.nix), [jellyfin.nix](../modules/services/website/jellyfin.nix), [plex-server.nix](../modules/services/website/plex-server.nix), [whoogle.nix](../modules/services/website/whoogle.nix), [code-server.nix](../modules/services/website/code-server.nix), [adguard.nix](../modules/services/website/adguard.nix)

### Other

- `mysql.nix`, `steam.nix`, `virtManager.nix`

## Server

Server configs. See [`modules/server/`](../modules/server/).

## Extras

Additional modules. See [`modules/extras/`](../modules/extras/).

## Usage

- Configure services in [`config.nix`](../config.nix)
- Import modules in `configuration.nix`
- Examples: [omnix/configuration.nix](../systems/omnix/configuration.nix), [server/configuration.nix](../systems/server/configuration.nix)

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
```
