{ pkgs, userConfig, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users."${userConfig.user.name}".extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [ docker-compose ];
}
