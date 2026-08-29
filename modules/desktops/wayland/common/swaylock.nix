# Swaylock - Lightweight screen locker (no Hyprland dependency)
{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.swaylock = {
    enable = lib.mkEnableOption "Swaylock screen locker";
  };

  config = lib.mkIf config.wayland.swaylock.enable {
    security.pam.services.swaylock = { };
    environment.systemPackages = [ pkgs.swaylock-effects ];
  };
}
