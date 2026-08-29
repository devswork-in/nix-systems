{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.swaync.enable =
    lib.mkEnableOption "SwayNC notification daemon";

  config = lib.mkIf config.wayland.swaync.enable {
    environment.systemPackages = [ pkgs.swaynotificationcenter ];
  };
}
