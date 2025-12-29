{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.waybar.enable = lib.mkEnableOption "Waybar status bar";

  config = lib.mkIf config.wayland.waybar.enable {
    # Add waybar package
    home-manager.users."${userConfig.user.name}".home.packages =
      [ pkgs.waybar ];
  };
}
