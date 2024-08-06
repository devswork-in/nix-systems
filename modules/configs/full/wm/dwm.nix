{ pkgs, config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;

  localDwm = pkgs.writeShellScriptBin "dwm" ''${link /home/${(import ../../config.nix).user}/dwm/dwm} "$@"'';
  localDwmBlocks = pkgs.writeShellScriptBin "dwmblocks" ''${link /home/${(import ../../config.nix).user}/dwmblocks/dwmblocks} "$@"'';
  dwm = if builtins.pathExists localDwm then localDwm else pkgs.dwm.overrideAttrs (old: {
    src = builtins.fetchTarball "https://github.com/creator54/dwm/tarball/main";
    nativeBuildInputs = with pkgs; [ #writing once works for both currently, sort of bug and feature
      xorg.libX11.dev
      xorg.libXft
      imlib2
      xorg.libXinerama
    ];
  });
  dwmblocks = if builtins.pathExists localDwmBlocks then localDwmBlocks else pkgs.dwmblocks.overrideAttrs (old: {
    src = builtins.fetchTarball "https://github.com/creator54/dwmblocks/tarball/master";
  });

  edwm = pkgs.writeShellScriptBin "edwm" ''${link ./edwm.sh}'';
in
{
  home.packages = [ dwm dwmblocks edwm ];
}
