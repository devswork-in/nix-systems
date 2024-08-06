{ config, pkgs, ... }:

let
  scriptsDir = "${config.home.homeDirectory}/nix-systems/modules/configs/full/scripts";
  binDir = "${config.home.homeDirectory}/.local/bin";

  fetchScript = name: url: pkgs.writeShellScriptBin name (builtins.readFile (builtins.fetchurl {
    url = url;
    sha256 = builtins.hashFile "sha256" (builtins.fetchurl {
      url = url;
    });
  }));

  livewall = fetchScript "livewall" "https://raw.githubusercontent.com/Creator54/livewall/main/livewall";
  ghv = fetchScript "ghv" "https://raw.githubusercontent.com/Creator54/ghv/main/ghv";
  wifiInterface = pkgs.writeShellScriptBin "wifiInterface" ''ip a | grep wlp | cut -d':' -f2| head -n1 |xargs'';

  symlinkScript = pkgs.writeShellScriptBin "symlinkScript" ''
    while true; do
      if [ ! -d "${binDir}" ]; then
        mkdir -p "${binDir}" || echo "Failed to create directory: ${binDir}" >&2
      fi

      for script in "${scriptsDir}"/*; do
        if [ ! -e "${binDir}/$(${pkgs.coreutils}/bin/basename "$script")" ]; then
          echo "Symlinking $script ..."
          ${pkgs.coreutils}/bin/ln -sf "$script" "${binDir}/$(${pkgs.coreutils}/bin/basename "$script")" || echo "Failed to symlink $script" >&2
        fi
      done

      ${pkgs.coreutils}/bin/sleep 5  # Adjust the sleep duration as needed
    done
  '';
in
{
  systemd.user.services.symlinkScripts = {
    Unit = {
      Description = "Symlink local scripts";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";

      ExecStart = "${pkgs.bash}/bin/bash -c '${symlinkScript}/bin/symlinkScript'";

      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };

  home.packages = [
    ghv livewall wifiInterface
  ];
}

