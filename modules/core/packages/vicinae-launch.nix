# Vicinae launcher wrapper - ensures server is running before launching UI
{ pkgs, ... }:

let
  vicinaeBin = pkgs.callPackage ../../core/packages/vicinae.nix {};
in
pkgs.writeShellScriptBin "vicinae-launch" ''
  #!/usr/bin/env bash
  set -euo pipefail

  VICINAE="${vicinaeBin}/bin/vicinae"
  CMD="''${1:-toggle}"

  # If the user explicitly asked to start the server, use --replace to handle orphans
  if [ "$CMD" = "server" ]; then
    exec "$VICINAE" server --replace
  fi

  # For all other commands (toggle, deeplink, etc.), ensure server is running
  if ! "$VICINAE" ping > /dev/null 2>&1; then
    # Start the server with --replace (handles any stale instances automatically)
    "$VICINAE" server --replace &
    # Wait for the server to be ready (up to 10 seconds)
    for i in $(seq 1 100); do
      if "$VICINAE" ping > /dev/null 2>&1; then
        break
      fi
      sleep 0.1
    done
  fi

  # Execute the requested command
  exec "$VICINAE" "$@"
''
