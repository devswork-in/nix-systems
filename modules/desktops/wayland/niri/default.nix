{ config, pkgs, lib, userConfig, inputs, ... }:

{

  # Import common Wayland components and Niri-specific modules
  imports = [
    ../common/environment.nix
    ../common/hyprlock
    ../common/waybar
    ../common/swaync
    ./environment.nix
    ./session-start.nix
  ];

  # Enable shared Wayland components
  wayland.hyprlock = {
    enable = true;
    autoLock = true; # Auto-lock on Niri startup
  };
  wayland.waybar.enable = true;
  wayland.swaync.enable = true;

  # Niri compositor
  programs.niri.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # System packages (Niri-specific and general Wayland tools)
  environment.systemPackages = with pkgs; [
    imv
    wlr-randr
    flameshot
    gromit-mpx
    screenkey
    swaybg
    brightnessctl
    playerctl
    blueman
    inputs.vicinae.packages.${pkgs.system}.default
    (pkgs.writeShellScriptBin "random-wallpaper" ''
      ${pkgs.procps}/bin/pkill swaybg || true
      WALLPAPER=$(find ~/Wallpapers -type f \( -name '*.jpg' -o -name '*.png' \) | ${pkgs.coreutils}/bin/shuf -n 1)
      ${pkgs.swaybg}/bin/swaybg -m fill -i "$WALLPAPER" &
    '')
  ];

  # Home Manager configuration
  home-manager.users."${userConfig.user.name}" = {
    # Import GTK configuration for theming
    imports = [ ../../../desktop-utils/gtk-config.nix ];

    home.packages = with pkgs; [ niri fuzzel networkmanagerapplet pavucontrol ];
  };
}
