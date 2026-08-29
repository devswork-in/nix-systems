{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.bat = {
    enable = true;
    settings = {
      theme = "zenburn";
      style = "grid";
    };
    extraPackages = with pkgs.bat-extras; [ batgrep batman batwatch prettybat batdiff ];
  };
}
