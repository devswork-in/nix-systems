# Zen Browser AppImage
{ pkgs, ... }:

let
  # Import mkAppImage helper from lib
  mkAppImage = import ../../../../lib/mkAppImage.nix { inherit pkgs; };
  
  zen-browser = mkAppImage {
    pname = "zen-browser";
    version = "1.7.6b";
    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/1.7.6b/zen-x86_64.AppImage";
      sha256 = "sha256-GJuxooMV6h3xoYB9hA9CaF4g7JUIJ2ck5/hiQp89Y5o=";
    };
    name = "Zen Browser";
    comment = "A modern and fast web browser";
    categories = "Network;WebBrowser;";
  };
in
{
  environment.systemPackages = [ zen-browser ];
}
