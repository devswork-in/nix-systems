{ config, pkgs, ... }:

let
  owner = "creator54";
  repo = "starter";
  rev = "main";

  nvimConfig =
    let
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      src =
        if builtins.pathExists "${config.home.homeDirectory}/.config/nvim" then
          "${config.home.homeDirectory}/.config/nvim"
        else
          builtins.fetchTarball url;
    in
    src;
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
  };

  # Do not combine and simplify as symlinking doesn't work properly
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfig;
  home.packages = [
    pkgs.luajit
    pkgs.ripgrep
  ]; # dep for some plugins, dep for file search
}
