{ config, lib, pkgs, userConfig, ... }:

with lib;

let
  cfg = config.programs.voquill;

  voquillApp = (import ../../../lib/mkAppImage.nix { inherit pkgs; }) {
    pname = "voquill";
    version = "0.0.644";
    name = "Voquill";
    src = pkgs.fetchurl {
      url = "https://github.com/voquill/voquill/releases/download/desktop-v0.0.644/voquill-desktop_0.0.644_amd64.AppImage";
      sha256 = "sha256-5vYImGJoI1E1km5LKFgF336QnSUeN2HWkuzjSOOl9D8=";
    };
    categories = "Utility;Audio;";
  };
in {
  options.programs.voquill = {
    enable = mkEnableOption "Voquill Dictation AppImage and dependencies";
  };

  config = mkIf cfg.enable {
    # 1. Enable ydotool daemon for Wayland keystroke injection
    programs.ydotool.enable = true;

    # 2. Add user to ydotool group automatically
    users.users.${userConfig.user.name}.extraGroups = [ "ydotool" ];

    # 3. Add the wrapped AppImage directly to the system (and wtype for input simulation)
    environment.systemPackages = [ voquillApp pkgs.wtype ];
  };
}
