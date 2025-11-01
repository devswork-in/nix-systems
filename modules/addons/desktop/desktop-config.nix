# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [
    ../../essential/configs/common/home-manager-base.nix
    ../../essential/command-scheduler/command-scheduler.nix
    ./copyq
  ];

  # Enable CopyQ clipboard manager
  services.copyq.enable = true;

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../../essential/packages/common
      ../../essential/packages/desktop
      ./environment.nix
    ];
  };
}
