{ config, pkgs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  user = (import ../../../config.nix {}).userName;
in 
{
  home-manager = {
    users."${user}" = { ... }: {
      home = {
        packages = with pkgs; [ kitty firefox ];
        file = {
          ".kitty/kitty.conf".source                                      = ./kitty.conf;
        };
      };
    };
  };
}

