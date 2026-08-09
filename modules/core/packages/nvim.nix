{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = true;
    withPython3 = true;
  };

  home = {
    packages = [ pkgs.luajit ]; # dep for some plugins
  };
}
