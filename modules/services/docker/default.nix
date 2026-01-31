{ pkgs, userConfig, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users."${userConfig.user.name}".extraGroups = [ "docker" ];
  environment.systemPackages = with pkgs; [ docker-compose ];
}
