# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [
    ../../essential/configs/common/home-manager-base.nix
    ../../essential/command-scheduler/command-scheduler.nix
  ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../../essential/packages/common
      ../../essential/packages/desktop
      ./environment.nix
    ];
  };
}
