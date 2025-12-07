# Base home-manager configuration for all systems
{ userConfig, ... }:

{
  imports = [
    ../configs/common/home-manager-base.nix
  ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../configs/common  # Import common environment configs
      ../packages  # Import common packages
    ];
  };
}