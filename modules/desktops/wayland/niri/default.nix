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
    swayosd
    rofi
    imagemagick
    (pkgs.callPackage ../../../core/packages/niri-sidebar.nix {})
    inputs.walker.packages.${pkgs.system}.default
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
  ];

  # Home Manager configuration
  home-manager.users."${userConfig.user.name}" = {
    # Import GTK configuration for theming
    imports = [ ../../../desktop-utils/gtk-config.nix ];

    home.packages = with pkgs; [ niri networkmanagerapplet pavucontrol ];

    # SwayOSD styling
    xdg.configFile."swayosd/style.css".text = ''
      window {
          background: rgba(17, 17, 27, 0.95); /* crust with opacity, matching waybar */
          border: 2px solid #585b70; /* surface2 */
          border-radius: 5px;
      }

      #container {
          margin: 10px;
          padding: 5px;
          border-radius: 5px;
      }

      image, label {
          color: #cdd6f4; /* text */
      }

      progressbar:disabled,
      image:disabled {
          opacity: 0.5;
      }

      progress, highlight {
          min-height: 6px;
          border-radius: 999px;
          background: #89b4fa; /* blue */
          border: none;
      }

      trough {
          background: #313244; /* surface0 */
          border-radius: 999px;
          border: none;
          min-height: 6px;
      }

      slider {
          background: #89b4fa; /* blue */
          border-radius: 999px;
          min-height: 6px;
          min-width: 6px;
          margin: -1px;
      }
    '';
  };
}
