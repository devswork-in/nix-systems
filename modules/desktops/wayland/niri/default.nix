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
    swayosd
    mpvpaper
    yt-dlp
    mpv
    socat
    inputs.vicinae.packages.${pkgs.system}.default
    (pkgs.writeShellScriptBin "random-wallpaper" ''
      ${pkgs.procps}/bin/pkill swaybg || true
      ${pkgs.procps}/bin/pkill mpvpaper || true
      WALLPAPER=$(find ~/Wallpapers -type f \( -name '*.jpg' -o -name '*.png' \) | ${pkgs.coreutils}/bin/shuf -n 1)
      ln -sf "$WALLPAPER" ~/.current_wallpaper
      ${pkgs.swaybg}/bin/swaybg -m fill -i "$WALLPAPER" &
    '')
    (pkgs.writeShellScriptBin "play-live-wallpaper" ''
      # Kill existing wallpapers
      ${pkgs.procps}/bin/pkill swaybg || true
      ${pkgs.procps}/bin/pkill mpvpaper || true

      # Get input from user
      INPUT=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu -p "YouTube Search/URL" -theme-str 'window {width: 500px;}')

      if [ -z "$INPUT" ]; then
        exit 0
      fi

      # Check if input is a URL (basic check)
      if [[ "$INPUT" =~ ^https?:// ]]; then
        URL="$INPUT"
      else
        # Search YouTube and get top 15 results
        # Format: Title [Channel] (Duration) | URL
        # We use yt-dlp to search and extract the info
        notify-send "Wallpaper" "Searching for: $INPUT..."

        RESULTS=$(${pkgs.yt-dlp}/bin/yt-dlp "ytsearch15:$INPUT" \
          --print "%(title)s   [%(channel)s]   (%(duration_string)s)|%(webpage_url)s" \
          --flat-playlist --no-warnings)

        if [ -z "$RESULTS" ]; then
          ${pkgs.libnotify}/bin/notify-send "Error" "No results found for: $INPUT"
          exit 1
        fi

        # Select with Rofi
        # We replace the pipe with a visual separator for the menu
        SELECTED=$(echo "$RESULTS" | sed 's/|/   ::   /g' | \
          ${pkgs.rofi}/bin/rofi -dmenu -p "Select Video" -theme-str 'window {width: 1000px;}')

        if [ -z "$SELECTED" ]; then
          exit 0
        fi

        # Extract URL (everything after "   ::   ")
        URL=$(echo "$SELECTED" | awk -F '   ::   ' '{print $2}')
      fi

      if [ -n "$URL" ]; then
        # Play the video on all monitors (*)
        # --mpv-options: Loop forever, enable socket for control
        ${pkgs.mpvpaper}/bin/mpvpaper -o "--loop --input-ipc-server=/tmp/mpvpaper-socket" '*' "$URL" &
      else
        ${pkgs.libnotify}/bin/notify-send "Error" "Invalid selection"
      fi
    '')
  ];

  # Home Manager configuration
  home-manager.users."${userConfig.user.name}" = {
    # Import GTK configuration for theming
    imports = [ ../../../desktop-utils/gtk-config.nix ];

    home.packages = with pkgs; [ niri fuzzel networkmanagerapplet pavucontrol ];

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
