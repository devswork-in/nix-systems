{ config, pkgs, ... }:
let
  nvimConfig = if builtins.pathExists "${config.home.homeDirectory}/nvim" then "${config.home.homeDirectory}/nvim" else (
    builtins.fetchTarball "https://github.com/creator54/starter/tarball/main"
  );
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  home = {
    file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfig;
    packages = [ pkgs.luajit ]; #dep for some plugins
  };
}

