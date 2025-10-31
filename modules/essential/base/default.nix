# Base home-manager configuration for all systems
{ userConfig, ... }:

{
  imports = [
    ../configs/common/home-manager-base.nix
  ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../packages/common  # Import common packages
    ];
  };
}