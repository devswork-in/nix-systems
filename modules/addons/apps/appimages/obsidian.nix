# Obsidian AppImage
{ pkgs, ... }:

let
  # Import mkAppImage helper from lib
  mkAppImage = import ../../../../lib/mkAppImage.nix { inherit pkgs; };
  
  obsidian = mkAppImage {
    pname = "obsidian";
    version = "1.8.4";
    src = pkgs.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.4/Obsidian-1.8.4.AppImage";
      sha256 = "sha256-f4waZvA/li0MmXVGj41qJZMZ7N31epa3jtvVoODmnKQ=";
    };
    name = "Obsidian";
    comment = "A modern and fast markdown note taking app";
    categories = "Utility;TextEditor;";
  };
in
{
  environment.systemPackages = [ obsidian ];
}
