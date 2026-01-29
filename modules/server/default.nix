# Complete server configuration
{ userConfig, ... }:

{
  imports = [ ../core ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../core/packages
    ];
  };
}
