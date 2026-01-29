# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [
    ../core
    ../apps/appimages
    ./nightlight.nix
    ./wallpaper.nix
    ./lockscreen.nix
  ];

  # Default enable desktop utilities
  nightlight.enable = lib.mkDefault true;
  desktop.wallpaper.enable = lib.mkDefault true;
  desktop.lockscreen.enable = lib.mkDefault true;
  desktop.lockscreen.autoLock = lib.mkDefault true;

  # CopyQ removed - using Vicinae clipboard manager instead
  # services.copyq.enable = true;

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ./packages

      ./fusuma.nix
      ./udiskie.nix
      ./polkit-agent.nix
    ];
  };
}
