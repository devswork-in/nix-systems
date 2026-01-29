{ config, pkgs, lib, userConfig, flakeRoot, ... }:

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
    # 1. Start DWMBlocks
    if [ -x ${localDwmBlocks}/dwmblocks ]; then
      ${localDwmBlocks}/dwmblocks &
    fi

    # 2. Start DWM
    if [ -x ${localDwm}/dwm ]; then
      exec ${localDwm}/dwm
    else
      echo "Error: Local DWM binary not found at ${localDwm}/dwm"
      echo "Please wait for dwm-builder service or build manually."
      exit 1
    fi
  '';

in {
  nixpkgs.config.allowUnsupportedSystem = true;

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;

    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
  };

  # Enable Blueman service (applet)
  services.blueman.enable = true;

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
    rofi
    xorg.xbacklight
    numlockx
    
    # Tools to match Niri functionality
    kitty
    flameshot
    playerctl
    brightnessctl
    gromit-mpx
    xclip
    bc
  ];

  environment.variables.USER_XSESSION_CMD = "${dwmSession}/bin/dwm-session";

  # Condition: Import DWM repos into syncItems ONLY if this module is imported/enabled
  services.nix-repo-sync.syncItems = syncConfig.dwm;

  # Auto-Builder Service
  systemd.user.services.dwm-builder = {
    description = "Auto-build dwm and dwmblocks from ~/.config";
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      bash
      coreutils
      gcc
      gnumake
      xorg.libX11
      xorg.libX11.dev
      xorg.libXft
      xorg.libXinerama
      xorg.xorgproto # Required for X11/X.h
      imlib2
      pkg-config
    ];
    serviceConfig = { Type = "oneshot"; };
    script = ''
      export PATH=${pkgs.bash}/bin:${pkgs.coreutils}/bin:$PATH
      
      # Inject include/lib paths for X11/Freetype and Xorgproto
      # We must include Xorgproto include path explicitly in CPATH for <X11/X.h>
      export CPATH=${pkgs.xorg.libX11.dev}/include:${pkgs.xorg.libXft.dev}/include:${pkgs.xorg.libXinerama.dev}/include:${pkgs.freetype.dev}/include/freetype2:${pkgs.xorg.xorgproto}/include:${pkgs.fontconfig.dev}/include:${pkgs.xorg.libXrender.dev}/include:$CPATH
      export LIBRARY_PATH=${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXft}/lib:${pkgs.xorg.libXinerama}/lib:${pkgs.imlib2}/lib:${pkgs.fontconfig.lib}/lib:${pkgs.xorg.libXrender}/lib:$LIBRARY_PATH
      
      # Override config.mk hardcoded paths by passing arguments to make
      # We rely on CPATH for header finding, so we don't need to override INCS manually with complex quoting
      BUILD_ARGS="X11INC=${pkgs.xorg.libX11.dev}/include/X11 X11LIB=${pkgs.xorg.libX11}/lib FREETYPEINC=${pkgs.freetype.dev}/include/freetype2"

      if [ -d "${localDwm}" ]; then
        make -C "${localDwm}" clean && make -C "${localDwm}" $BUILD_ARGS
      fi
      if [ -d "${localDwmBlocks}" ]; then
        make -C "${localDwmBlocks}" clean && make -C "${localDwmBlocks}" $BUILD_ARGS
      fi
    '';
  };

  # Set session manager options for DWM
  sessionManager = {
    sessionCommand = "startx";
    sessionType = "x11";
  };

  # Enable dconf (required for Home Manager dconf settings)
  programs.dconf.enable = true;
}
