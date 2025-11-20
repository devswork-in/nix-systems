# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [
    ../core
    ./copyq
  ];

  # Enable CopyQ clipboard manager
  services.copyq.enable = true;

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ./packages
      ./environment.nix
      ./fusuma.nix
      ./firefox
    ];
  };
}
