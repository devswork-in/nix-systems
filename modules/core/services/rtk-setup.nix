# Auto-setup rtk OpenCode plugin on first login
{ pkgs, userConfig, ... }:

let
  user = userConfig.user.name;
  home = userConfig.user.home or "/home/${user}";
  rtk = pkgs.callPackage ../packages/rtk.nix {};
in
{
  systemd.user.services.rtk-setup = {
    description = "Setup rtk OpenCode plugin (runs once)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "rtk-setup" ''
        PLUGIN="${home}/.config/opencode/plugins/rtk.ts"
        if [ ! -f "$PLUGIN" ]; then
          ${rtk}/bin/rtk init -g --opencode --auto-patch
        fi
      '');
      RemainAfterExit = true;
    };
  };
}
