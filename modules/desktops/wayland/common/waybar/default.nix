{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.waybar.enable = lib.mkEnableOption "Waybar status bar";

  config = lib.mkIf config.wayland.waybar.enable {
    environment.systemPackages = [ pkgs.waybar ];
  };
}
