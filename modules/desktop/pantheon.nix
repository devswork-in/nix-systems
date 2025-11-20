{ pkgs, ... }:

{
  services = {
    xserver = {
      desktopManager = {
        pantheon = {
          enable = true;
          extraWingpanelIndicators = [ ];
          extraSwitchboardPlugs = [ pkgs.pantheon-tweaks ];
        };
      };
      displayManager = {
        autoLogin.user = (import ../../userConfig.nix).userName;
        lightdm = {
          # gets enabled by default
          enable = true;
          greeters.pantheon.enable = true;
        };
      };
    };
    pantheon.apps.enable = true;
    power-profiles-daemon.enable = false;
  };
  # some apps still comes with the default setup so disabled here
  environment.pantheon.excludePackages = with pkgs; [
    gnome3.geary
    epiphany
  ];
  environment.systemPackages = with pkgs; [
    pantheon.elementary-code
    gnome3.dconf-editor
  ];
}
