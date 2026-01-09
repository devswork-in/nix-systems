{ pkgs, userConfig, lib, ... }:

{
  environment.systemPackages = with pkgs; [ virt-manager virt-viewer quickemu ];
  users.users."${userConfig.user.name}".extraGroups = [ "libvirtd" ];
  virtualisation = { libvirtd.enable = true; };

  # Prevent boot start
  systemd.services.libvirtd.wantedBy = lib.mkForce [ ];

  # Delayed start timer
  systemd.timers.libvirtd-delayed = {
    wantedBy = [ "graphical.target" ];
    timerConfig = {
      OnActiveSec = "2m";
      Unit = "libvirtd.service";
    };
  };
}
