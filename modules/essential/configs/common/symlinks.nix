# Essential symlinks configuration
{ config, pkgs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    # Nixpkgs configuration
    ".config/nixpkgs/config.nix".source = ../../../common/config.nix;

    # General aliases file
    ".config/aliases".source = ./aliases;

    # Htop configuration
    ".config/htop/htoprc".source = ./htop/htoprc;

    # Tmux configuration
    ".tmux.conf".source = ./tmux.conf;

    # Bash configuration
    ".bashrc".source = ./bashrc;

    # Fish configuration (only the files that are not handled by programs.fish)
    ".config/fish/fish_variables".source = ./fish/fish_variables;


    ".config/fish/functions/fish_prompt.fish".source = ./fish/functions/fish_prompt.fish;
    ".config/fish/functions/fish_right_prompt.fish".source = ./fish/functions/fish_right_prompt.fish;
    ".config/fish/functions/fish_greeting.fish".source = ./fish/functions/fish_greeting.fish;
    ".config/fish/functions/__fish_command_not_found_handler.fish".source = ./fish/functions/__fish_command_not_found_handler.fish;
    ".config/fish/completions/.gitkeep".text = "";
    ".config/fish/conf.d/.gitkeep".text = "";

    # Standalone scripts available in PATH
    ".local/bin/fgit".source = ./scripts/fgit;
    ".local/bin/fgit".executable = true;
  };
}