# Vicinae AppImage - avoids building from source
{ pkgs, ... }:

let
  vicinaeAppImage = pkgs.fetchurl {
    url = "https://github.com/vicinaehq/vicinae/releases/download/v0.20.10/Vicinae-x86_64.AppImage";
    hash = "sha256-lUU6ISidloqs4dKYjCS4MNEQTkuJ6yuxD4jR2RvJ0xk=";
  };
in
pkgs.appimageTools.wrapType2 {
  pname = "vicinae";
  version = "0.20.10";
  src = vicinaeAppImage;
}
