{ config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/nixpkgs/config.nix".source                   = ./config.nix;
    ".config/home-manager/home.nix".source                = ../home.nix;
    ".config/fish".source                                 = ./fish;
    ".config/starship.toml".source                        = ./starship.toml;
    ".config/htop".source                                 = ./htop;
    ".tmux.conf".source                                   = ./tmux.conf;
    ".bashrc".source                                      = ./bashrc;
  };
}
