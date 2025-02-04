{
  config,
  lib,
  pkgs,
  ...
}:

let
  scriptsDir = "${config.home.homeDirectory}/nix-systems/modules/configs/full/scripts";
  binDir = "${config.home.homeDirectory}/.local/bin";

  fetchScript =
    name: url:
    pkgs.writeShellScriptBin name (
      builtins.readFile (
        builtins.fetchurl {
          url = url;
          sha256 = builtins.hashFile "sha256" (
            builtins.fetchurl {
              url = url;
            }
          );
        }
      )
    );

  livewall = fetchScript "livewall" "https://raw.githubusercontent.com/Creator54/livewall/main/livewall";
  ghv = fetchScript "ghv" "https://raw.githubusercontent.com/Creator54/ghv/main/ghv";
  wifiInterface = pkgs.writeShellScriptBin "wifiInterface" ''ip a | grep wlp | cut -d':' -f2| head -n1 |xargs'';

  symlinkScripts = pkgs.writeShellScriptBin "symlinkScripts" ''
    mkdir -p "${binDir}"

    for script in "${scriptsDir}"/*; do
      ln -sf "$script" "${binDir}/$(basename "$script")"
    done
  '';
in
{
  home.packages = [
    ghv
    livewall
    wifiInterface
    symlinkScripts
  ];

  # Run the symlink script when home-manager is activated
  home.activation.symlinkScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${symlinkScripts}/bin/symlinkScripts
  '';
}
