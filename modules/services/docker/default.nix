{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = config.nixSystems.role == "server";
    enableOnBoot = config.nixSystems.role == "server";
    autoPrune = {
      enable = config.nixSystems.role == "server";
      dates = "weekly";
      flags = [ "--all" ];
    };
    rootless = {
      enable = config.nixSystems.role == "desktop";
      setSocketVariable = config.nixSystems.role == "desktop";
    };
  };
  environment.systemPackages = with pkgs; [ docker-compose ];
}
