# Modules

Available modules and services.

## Essential Modules

Core functionality included via profiles. See [`modules/essential/`](../modules/essential/).

- `base/` - System configuration
- `packages/` - Package sets (common, server, desktop)
- `configs/` - Config files (common, server, desktop)

## Addon Modules

Optional features, explicitly imported. See [`modules/addons/`](../modules/addons/).

### Desktop

**GNOME + Pop Shell** - [`pop-shell.nix`](../modules/addons/desktop/pop-shell.nix)

```nix
imports = [ ./modules/addons/desktop/pop-shell.nix ];
```

**Other:**
- `pantheon.nix` - Pantheon desktop
- `bluetooth.nix` - Bluetooth support
- `plymouth.nix` - Boot splash
- `redshift.nix` - Screen temperature
- `tlp.nix` - Power management

### Applications

**AppImages** - [`apps/appimages/`](../modules/addons/apps/appimages/)

```nix
imports = [
  ./modules/addons/apps/appimages/zen-browser.nix
  ./modules/addons/apps/appimages/obsidian.nix
];
```

### Services

```nix
imports = [ ./modules/addons/services/docker ];
services.flatpak.enable = true;
services.snapd.enable = true;
```

## Web Services

Configure in [`config.nix`](../config.nix). See [`modules/addons/services/website/`](../modules/addons/services/website/).

```nix
services = {
  nextCloud = { enable = true; adminUser = "admin"; host = "cloud.domain.com"; };
  jellyfin = { enable = true; user = "user"; host = "tv.domain.com"; port = 8096; };
  plex = { enable = true; user = "user"; host = "plex.domain.com"; port = 32400; };
  whoogle = { enable = true; host = "search.domain.com"; port = "8050"; };
  codeServer = { enable = true; host = "code.domain.com"; user = "user"; port = 5000; };
  adguard = { enable = true; host = "ag.domain.com"; port = 3000; };
  website = { enable = true; https = true; };
};
```

## Enable/Disable

Edit [`config.nix`](../config.nix):

```nix
services.nextCloud.enable = true;
```

Or add imports to system's `configuration.nix`:

```nix
imports = [
  ../../modules/addons/services/docker
  ../../modules/addons/apps/appimages/zen-browser.nix
];
```

Rebuild:

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
```
