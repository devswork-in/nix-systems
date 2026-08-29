{ config, pkgs, lib, userConfig, inputs, ... }:

{

  # Import common Wayland components and Niri-specific modules
  imports = [
    ../common/environment.nix
    ../common/swaylock.nix
    ../common/waybar
    ../common/swaync
    ./environment.nix
    ./session-start.nix
    ../../../core/packages/walker.nix
    ../../../desktop-utils/gtk-config.nix
  ];

  # Enable shared Wayland components
  wayland.swaylock = {
    enable = true;
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

  systemd.services.bluetooth-rfkill-unblock = {
    description = "Unblock Bluetooth before BlueZ starts";
    before = [ "bluetooth.service" ];
    wantedBy = [ "bluetooth.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  # System packages (Niri-specific and general Wayland tools)
  environment.systemPackages = with pkgs; [
    imv
    wlr-randr
    # flameshot
    gromit-mpx
    screenkey
    swaybg
    brightnessctl
    playerctl
    blueman
    swayosd
    xwayland-satellite
    imagemagick
    (pkgs.callPackage ../../../core/packages/swiv.nix {})
    (pkgs.callPackage ../../../core/packages/niri-sidebar.nix {})
    inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.writeShellScriptBin "random-wallpaper" ''
      # Kill any existing wallpaper processes (static and live)
      ${pkgs.procps}/bin/pkill swaybg || true
      ${pkgs.procps}/bin/pkill mpvpaper || true
      ${pkgs.procps}/bin/pkill mpv || true
      WALLPAPER=$(find ~/Wallpapers -type f \( -name '*.jpg' -o -name '*.png' \) | ${pkgs.coreutils}/bin/shuf -n 1)
      ln -sf "$WALLPAPER" ~/.current_wallpaper
      ${pkgs.swaybg}/bin/swaybg -m fill -i "$WALLPAPER" &
    '')
    (pkgs.writeShellScriptBin "wallpaper-selector" (builtins.readFile ../../../core/configs/common/scripts/wallpaper-selector))
    inputs.livewall.packages.${pkgs.stdenv.hostPlatform.system}.default
    niri
    networkmanagerapplet
    pavucontrol
  ];
}
