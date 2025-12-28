{ config, pkgs, lib, userConfig, flakeRoot, inputs, ... }:

let
  # dynamic user
  user = userConfig.user.name;
  homeDir = config.users.users.${user}.home;

  # Import sync config to get DWM repos conditionally
  syncConfig = import ../../../../sync-config.nix {
    inherit flakeRoot;
    user = userConfig.user;
    paths = userConfig.paths;
  };

  # Local source paths matching sync-config.nix
  localDwm = "${homeDir}/.config/dwm";
  localDwmBlocks = "${homeDir}/.config/dwmblocks";

  # Session Script - Strict Local Execution
  dwmSession = pkgs.writeShellScriptBin "dwm-session" ''
    # Build flags for NixOS
    export X11INC="${pkgs.xorg.libX11.dev}/include"
    export X11LIB="${pkgs.xorg.libX11}/lib"
    export FREETYPEINC="${pkgs.xorg.libXft.dev}/include/freetype2"
    BUILD_FLAGS="X11INC=$X11INC X11LIB=$X11LIB FREETYPEINC=$FREETYPEINC"

    # Set Background
    ${pkgs.feh}/bin/feh --bg-fill ${../../gnome/wallpaper.jpg} &

    # Start Vicinae Server
    ${inputs.vicinae.packages.${pkgs.system}.default}/bin/vicinae server &

    # 1. Start DWMBlocks
    if [ -d ${localDwmBlocks} ]; then
        if [ ! -x ${localDwmBlocks}/dwmblocks ]; then
            echo "DWMBlocks binary missing. Building..."
            make -C ${localDwmBlocks} clean
            make -C ${localDwmBlocks} $BUILD_FLAGS
        fi
        ${localDwmBlocks}/dwmblocks &
    fi

    # 2. Start DWM
    if [ -d ${localDwm} ]; then
        if [ ! -x ${localDwm}/dwm ]; then
            echo "DWM binary missing. Building..."
            make -C ${localDwm} clean
            make -C ${localDwm} $BUILD_FLAGS
        fi
        
        if [ -x ${localDwm}/dwm ]; then
            exec ${localDwm}/dwm
        else
            echo "Failed to build DWM. Falling back to xterm to prevent lockout."
            exec xterm
        fi
    else
      echo "Error: Local DWM source not found at ${localDwm}"
      exec xterm
    fi
  '';

in {
  nixpkgs.config.allowUnsupportedSystem = true;
  programs.dconf.enable = true;

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    mouse.naturalScrolling = true;
  };

  programs.light.enable = true;

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;

    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
  };

  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    xorg.libX11
    xorg.libX11.dev
    xorg.libXft
    xorg.libXinerama
    imlib2
    dwm
    dwmblocks
    dmenu
    dunst
    libnotify
    feh
    feh
    inputs.vicinae.packages.${pkgs.system}.default
    flameshot
    kitty
    betterlockscreen
    light
    gromit-mpx
    maim
    xclip
    sxiv
    nnn
    alsa-utils
    xorg.xbacklight

    # Utilities needed for xinitrc
    picom
    networkmanagerapplet
    numlockx
    xorg.xrdb
    xterm
  ];

  environment.variables.USER_XSESSION_CMD = "${dwmSession}/bin/dwm-session";

  # Condition: Import DWM repos into syncItems ONLY if this module is imported/enabled
  services.nix-repo-sync.syncItems = syncConfig.dwm;

  # Auto-Builder Service
  systemd.user.services.dwm-builder = {
    description = "Auto-build dwm and dwmblocks from ~/.config";
    wantedBy = [ "graphical-session-pre.target" ];
    partOf = [ "graphical-session-pre.target" ];
    path = with pkgs; [
      coreutils
      gcc
      gnumake
      xorg.libX11
      xorg.libX11.dev
      xorg.libXft
      xorg.libXinerama
      imlib2
    ];
    serviceConfig = { Type = "oneshot"; };
    script = ''
      # NixOS-friendly build flags
      export X11INC="${pkgs.xorg.libX11.dev}/include"
      export X11LIB="${pkgs.xorg.libX11}/lib"
      export FREETYPEINC="${pkgs.xorg.libXft.dev}/include/freetype2"

      BUILD_FLAGS="X11INC=$X11INC X11LIB=$X11LIB FREETYPEINC=$FREETYPEINC"

      if [ -d "${localDwm}" ]; then
        make -C "${localDwm}" clean && make -C "${localDwm}" $BUILD_FLAGS
      fi
      if [ -d "${localDwmBlocks}" ]; then
        make -C "${localDwmBlocks}" clean && make -C "${localDwmBlocks}" $BUILD_FLAGS
      fi
    '';
  };
}
