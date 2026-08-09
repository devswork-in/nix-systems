{ config, lib, userConfig, ... }:

let
  user = userConfig.user.name;
  envDir = "/home/${user}/.config/env";
  roleFile = ./. + "/${config.nixSystems.role}.sh";
  hostFile = ./. + "/${config.networking.hostName}.sh";
in {
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "bat";
    BROWSER = "zen-browser";
    TERMINAL = "kitty";
    READER = "zathura";

    # System Identity Variables
    NIX_CONFIG_DIR = "/etc/nixos";
    NIX_SYSTEM = config.networking.hostName;
  };

  systemd.tmpfiles.rules = [
    "d ${envDir} 0755 ${user} users - -"
    "L+ ${envDir}/common.sh - ${user} users - ${./common.sh}"
    "L+ ${envDir}/${config.nixSystems.role}.sh - ${user} users - ${roleFile}"
  ] ++ lib.optional (builtins.pathExists hostFile)
    "L+ ${envDir}/${config.networking.hostName}.sh - ${user} users - ${hostFile}";
}
