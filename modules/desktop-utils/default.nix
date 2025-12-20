# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [ ../core ./copyq ../apps/appimages ];

  # Enable CopyQ clipboard manager
  services.copyq.enable = true;

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ./packages

      ./fusuma.nix
    ];
  };
}
