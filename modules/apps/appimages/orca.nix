# StablyAI Orca IDE AppImage
{ pkgs, ... }:

let
  mkAppImage = import ../../../lib/mkAppImage.nix { inherit pkgs; };

  orca = mkAppImage {
    pname = "orca";
    version = "1.4.179";
    src = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v1.4.179/orca-linux.AppImage";
      hash = "sha256-B4CEhW22bSmya1dguIAo3pWv/NdxQxNZ7uNpJCl7EN8=";
    };
    name = "Orca";
    comment = "AI coding agent IDE";
    categories = "Development;IDE;";
  };
in
{
  environment.systemPackages = [ orca ];
}
