# Complete server configuration
{ userConfig, ... }:

{
  imports = [
    ./configs/common/home-manager-base.nix
  ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ./packages/common
      ./packages/server
      ./configs/server/environment.nix
    ];
  };
}