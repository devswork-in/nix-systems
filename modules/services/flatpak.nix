{ pkgs, lib, ... }:

{
  # Flatpak service - disabled to improve boot time (was causing flatpak-managed-install.service to take 1.8s)
  # To use Flatpak: systemctl enable --now flatpak
  services.flatpak = {
    enable = true; # Enabled but delayed
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      {
        appId = "io.github.thetumultuousunicornofdarkness.cpu-x";
        origin = "flathub";
      }
      {
        appId = "io.github.jeffshee.Hidamari";
        origin = "flathub";
      }
      {
        appId = "io.webtorrent.WebTorrent";
        origin = "flathub";
      }
    ];

    update.auto = {
      enable =
        false; # Changed to false - was causing flatpak-managed-install at boot
      onCalendar = "weekly"; # Default value
    };
  };

  # Prevent managed install service from running at boot
  systemd.services.flatpak-managed-install.wantedBy = lib.mkForce [ ];

  # Delayed start timer
  systemd.timers.flatpak-managed-install-delayed = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      Unit = "flatpak-managed-install.service";
    };
  };

  xdg.portal = {
    enable = lib.mkForce true;
    config.common.default = "*";
    # Consider removing extraPortals if it causes conflicts
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Only add flatpak binaries to PATH if flatpak is enabled
  # This avoids the shellInit from running during boot unnecessarily
  environment.shellInit = ''
    # Only run flatpak binary setup if flatpak is enabled
    if command -v flatpak >/dev/null 2>&1; then
      FLATPAK_BIN_DIR="/var/lib/flatpak/exports/bin"
      LOCAL_BIN_DIR="$HOME/.local/bin"

      mkdir -p "$LOCAL_BIN_DIR"

      for item in "$FLATPAK_BIN_DIR"/*; do
        [ -x "$item" ] || continue
        flatpak_short_alias="''${item##*.}"
        flatpak_long_alias="''${item##*/}"

        # Create a symlink for the short alias if it doesn't conflict
        if [ ! -f "$LOCAL_BIN_DIR/$flatpak_short_alias" ] && [ -z "$(command -v "$flatpak_short_alias")" ]; then
          ln -sf "$item" "$LOCAL_BIN_DIR/$flatpak_short_alias"
        # Create a symlink for the long alias if it doesn't conflict
        elif [ ! -f "$LOCAL_BIN_DIR/$flatpak_long_alias" ] && [ -z "$(command -v "$flatpak_long_alias")" ]; then
          ln -sf "$item" "$LOCAL_BIN_DIR/$flatpak_long_alias"
        fi
      done

      export PATH="$LOCAL_BIN_DIR:$PATH"
    fi
  '';

}
