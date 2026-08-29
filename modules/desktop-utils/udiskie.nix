{ pkgs, ... }:

let
  config = (pkgs.formats.yaml { }).generate "udiskie.yml" {
    program_options = { automount = true; notify = true; tray = "auto"; udisks_version = 2; };
    icon_names.media = [ "drive-removable-media" ];
  };
in {
  environment.systemPackages = [ pkgs.udiskie ];
  systemd.user.services.udiskie = {
    description = "udiskie mount daemon";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie --config=${config}";
  };
}
