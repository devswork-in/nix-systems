{ pkgs, ... }:

let
  nnnPluginsSrc = pkgs.fetchFromGitHub {
    owner = "jarun";
    repo = "nnn";
    rev = "master";
    hash = "sha256-Svs2pNInxPymrgkyCfPqWcCh/G82J+Ak2MnraZwfWrY=";
  };
in
{
  home.packages = with pkgs; [
    (nnn.override { withNerdIcons = true; })
    # Previewer dependencies for preview-tui and nnn plugins
    chafa
    poppler-utils
    mediainfo
    ffmpegthumbnailer
    mpv
    imagemagick
    exiftool
    atool
    eza
    bat
    glow
  ];

  home.sessionVariables = {
    NNN_PREVIEWIMGPROG = "kitty";
  };

  # Declaratively link all plugins from jarun/nnn master branch
  home.file.".config/nnn/plugins".source = "${nnnPluginsSrc}/plugins";
}
