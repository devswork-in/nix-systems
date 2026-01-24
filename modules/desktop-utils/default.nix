# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [ ../core ../apps/appimages ];

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
