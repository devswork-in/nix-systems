{ pkgs, lib, ... }:

{
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      {
        appId = "io.github.thetumultuousunicornofdarkness.cpu-x";
        origin = "flathub";
      }
      # {
      #   appId = "io.github.jeffshee.Hidamari";
      #   origin = "flathub";
      # }
      {
        appId = "io.webtorrent.WebTorrent";
        origin = "flathub";
      }
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  systemd.services.flatpak-managed-install.wantedBy = lib.mkForce [ ];
  systemd.timers.flatpak-managed-install = {
    wantedBy = [ "timers.target" ];
    timerConfig = lib.mkForce {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
      Unit = "flatpak-managed-install.service";
    };
  };

  xdg.portal = {
    enable = lib.mkForce true;
    config.common.default = "*";
    # Consider removing extraPortals if it causes conflicts
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
