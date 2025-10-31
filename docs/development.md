# Development

Extending and testing the system.

## Module Creation

All modules accept `userConfig` parameter:

```nix
{ config, pkgs, lib, userConfig, ... }:
{
  users.users.${userConfig.user.name} = { ... };
  services.myservice.enable = userConfig.services.myservice.enable or false;
}
```

### Essential vs Addon

**Essential** - Core functionality, in [`modules/essential/`](../modules/essential/), included via profiles

**Addon** - Optional features, in [`modules/addons/`](../modules/addons/), explicitly imported

### Create Addon

```bash
touch modules/addons/myfeature/default.nix
```

```nix
{ config, pkgs, userConfig, ... }:
{
  environment.systemPackages = with pkgs; [ mypackage ];
  services.myservice = { enable = true; user = userConfig.user.name; };
}
```

Import in system:

```nix
imports = [ ../../modules/addons/myfeature ];
```

Test:

```bash
sudo nixos-rebuild switch --flake .#mysystem --impure
```

## AppImages

Use [`mkAppImage`](../lib/mkAppImage.nix):

```nix
{ pkgs, ... }:
let
  mkAppImage = import ../../../../lib/mkAppImage.nix { inherit pkgs; };
in
{
  environment.systemPackages = [
    (mkAppImage {
      name = "myapp";
      version = "1.0.0";
      src = pkgs.fetchurl {
        url = "https://example.com/myapp.AppImage";
        sha256 = "...";  # nix-prefetch-url <url>
      };
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "myapp";
          desktopName = "My App";
          exec = "myapp";
          categories = [ "Utility" ];
        })
      ];
    })
  ];
}
```

## Testing

```bash
sudo nixos-rebuild build --flake .#<hostname>                    # Build only
sudo nixos-rebuild test --flake .#<hostname> --impure            # Test without making default
sudo nixos-rebuild dry-build --flake .#<hostname>                # Dry run

nix run nixpkgs#nixos-rebuild -- build-vm --flake .#<hostname> --fast  # VM test
./result/bin/run-*-vm

nix flake check                                                  # Check syntax
```