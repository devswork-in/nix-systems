{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  home = {
    packages = [ pkgs.luajit ]; # dep for some plugins
  };
}
