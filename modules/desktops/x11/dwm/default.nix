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
      if [ -d "${localDwm}" ]; then
        make -C "${localDwm}" clean && make -C "${localDwm}"
      fi
      if [ -d "${localDwmBlocks}" ]; then
        make -C "${localDwmBlocks}" clean && make -C "${localDwmBlocks}"
      fi
    '';
  };
}
