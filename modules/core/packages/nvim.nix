{ pkgs, ... }:

{
  # Keep loading the repository-synced user config; the NixOS Neovim module
  # intentionally changes that behavior.
  environment.systemPackages = with pkgs; [ neovim luajit ];
  environment.shellAliases = { vi = "nvim"; vim = "nvim"; };
}
