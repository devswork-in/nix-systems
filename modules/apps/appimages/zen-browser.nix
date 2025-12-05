# Zen Browser AppImage
{ pkgs, ... }:

let
  # Import mkAppImage helper from lib
  mkAppImage = import ../../../lib/mkAppImage.nix { inherit pkgs; };
  
  zen-browser = mkAppImage {
    pname = "zen-browser";
    version = "1.17.12b";
    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/1.17.12b/zen-x86_64.AppImage";
      sha256 = "sha256:a5a87189dbcc2f1b524f8c6122d5c8e799d14f8d13582923b2758a6f7ed9ac09";
    };
    name = "Zen Browser";
    comment = "A modern and fast web browser";
    categories = "Network;WebBrowser;";
  };
in
{
  environment.systemPackages = [ zen-browser ];
}
