{ pkgs, ... }:

let
  nix-flatpak-src = builtins.fetchTarball {
    url = "https://github.com/gmodena/nix-flatpak/archive/refs/tags/v0.4.1.tar.gz";
    sha256 = "sha256:1drg6fjv7q0lpx5gmb6rda3l2f3b25fb200fh3dchqjm176p3g97";
  };
  nix-flatpak = import "${nix-flatpak-src}/modules/nixos.nix";
in
{
  imports = [ nix-flatpak ];

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      { appId = "io.github.thetumultuousunicornofdarkness.cpu-x"; origin = "flathub"; }
      { appId = "io.webtorrent.WebTorrent"; origin = "flathub"; }
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

environment.shellInit = ''
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
'';


}

