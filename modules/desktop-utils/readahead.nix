{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.readahead;
in {
  options.services.readahead = {
    enable = mkEnableOption "readahead service for boot-time file preloading";

    fileList = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of files/directories to pre-load into page cache at boot";
    };
  };

  config = mkIf cfg.enable {
    # Systemd oneshot service that reads common app files into page cache
    systemd.services.readahead = {
      description = "Pre-load frequently used files into page cache for faster app launch";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        Nice = "19";
        IOSchedulingClass = "idle";
        ExecStart = pkgs.writeShellScript "readahead-boot" ''
          ${lib.concatMapStrings (path: ''
            if [ -e "${path}" ]; then
              ${pkgs.coreutils}/bin/cat "${path}" > /dev/null 2>&1 || true
            fi
          '') cfg.fileList}
        '';
      };
    };
  };
}
