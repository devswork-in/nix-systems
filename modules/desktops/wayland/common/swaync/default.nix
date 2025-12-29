{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.swaync.enable =
    lib.mkEnableOption "SwayNC notification daemon";

  config = lib.mkIf config.wayland.swaync.enable {
    # Add swaynotificationcenter package
    home-manager.users."${userConfig.user.name}".home.packages =
      [ pkgs.swaynotificationcenter ];
  };
}
