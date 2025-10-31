{ pkgs, ... }:

{
  # Import individual AppImage modules
  imports = [
    ./zen-browser.nix
    ./obsidian.nix
  ];
}
