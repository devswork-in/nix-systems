{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nix-store-prewarm;

  scriptTemplate = builtins.readFile ./nix-store-prewarm.sh;

  pkgPathsStr = lib.concatStringsSep " " (map (pkg: toString (pkg.outPath or pkg)) cfg.packages);

  scriptContent = lib.replaceStrings
    [ "@@NIX@@" "@@FINDUTILS@@" "@@COREUTILS@@" "@@DELAY@@" "@@MAX_SIZE_MB@@" "@@PKG_PATHS@@" ]
    [ "${pkgs.nix}" "${pkgs.findutils}" "${pkgs.coreutils}" (toString cfg.delay) (toString cfg.maxFileSizeMB) pkgPathsStr ]
    scriptTemplate;

  prewarmScript = pkgs.writeShellScript "nix-store-prewarm" scriptContent;
in
{
  options.services.nix-store-prewarm = {
    enable = mkEnableOption "Nix store pre-warming service at boot";

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Packages whose store paths should be pre-warmed at boot";
    };

    delay = mkOption {
      type = types.int;
      default = 30;
      description = "Seconds to wait after boot before starting pre-warm";
    };

    maxFileSizeMB = mkOption {
      type = types.int;
      default = 100;
      description = "Skip files larger than this (MB) to avoid warming massive binaries like Chrome";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nix-store-prewarm = {
      description = "Pre-warm Nix store paths for commonly-used applications";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        Nice = "19";
        IOSchedulingClass = "idle";
        CPUSchedulingPolicy = "idle";
        ExecStart = "${prewarmScript}";
      };
    };
  };
}
