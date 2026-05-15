{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home = {
    packages = [ pkgs.luajit ]; # dep for some plugins
  };
}