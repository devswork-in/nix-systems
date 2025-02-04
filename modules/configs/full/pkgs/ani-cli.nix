{ pkgs, lib, ... }:

let
  src = builtins.fetchTarball "https://github.com/pystardust/ani-cli/archive/master.tar.gz";
  sha256 = builtins.hashFile src;

  ani-cli-latest = pkgs.ani-cli.overrideAttrs (old: {
    src = src;
  });
in
{
  home.packages = [ ani-cli-latest ];
}
