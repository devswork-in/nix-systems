{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = [
    (if inputs ? awrit && inputs.awrit ? packages && inputs.awrit.packages ? ${system}
     then inputs.awrit.packages.${system}.awrit
     else pkgs.awrit)
  ];
}