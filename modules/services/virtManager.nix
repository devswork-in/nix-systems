{ pkgs, userConfig, lib, ... }:

{
  environment.systemPackages = with pkgs; [ virt-manager virt-viewer quickemu ];
  users.users."${userConfig.user.name}".extraGroups = [ "libvirtd" ];
  virtualisation = { libvirtd.enable = true; };

  # Prevent boot start
  systemd.services.libvirtd.wantedBy = lib.mkForce [ ];

  # Disable auto-resume of VMs on boot (no VMs configured)
  systemd.services.libvirt-guests.enable = lib.mkForce false;

  # Disable libvirtd config generation on boot (saves ~300ms)
  systemd.services.libvirtd-config.enable = lib.mkForce false;

  # Delayed start timer
  systemd.timers.libvirtd-delayed = {
    wantedBy = [ "graphical.target" ];
    timerConfig = {
      OnActiveSec = "2m";
      Unit = "libvirtd.service";
    };
  };
}
