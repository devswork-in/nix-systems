{
  config,
  pkgs,
  lib,
  ...
}:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    source-code-pro
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
