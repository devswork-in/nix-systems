{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = config.nixSystems.role == "server";
    enableOnBoot = config.nixSystems.role == "server";
    autoPrune = {
      enable = config.nixSystems.role == "server";
      dates = "daily";
      flags = [ "--all" "--volumes" ];
    };
    rootless = {
      enable = config.nixSystems.role == "desktop";
      setSocketVariable = config.nixSystems.role == "desktop";
    };
  };
  # Desktop Docker idles at ~240 MB; start it on demand: systemctl --user start docker
  systemd.user.services.docker.wantedBy =
    lib.mkIf (config.nixSystems.role == "desktop") (lib.mkForce [ ]);
  environment.systemPackages = with pkgs; [ docker-compose ];
}
