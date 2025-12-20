# Common configuration files for all systems
{ config, pkgs, ... }:

{
  imports = [
    # ./symlinks.nix  # Disabled: Using repo-sync for symlinks instead (allows writable configs)
  ];
}
