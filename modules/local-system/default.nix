{ pkgs, ... }:

let
  cursorApp = import ./cursor.nix { inherit pkgs; };
in
{
  imports = [
    ./extras
    ./tlp.nix
    ./plymouth.nix
    ./services.nix
    ./bluetooth.nix
    ./kernels/xanmod.nix
    ./desktop/pop-shell.nix
  ];

  environment.systemPackages = with pkgs; [ cursorApp ];
}
