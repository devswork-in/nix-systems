{ pkgs, ... }:
let
  config = (import ../../../config.nix { });
in
{
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    quickemu
  ];
  users.users."${config.userName}".extraGroups = [ "libvirtd" ];
  virtualisation = {
    libvirtd.enable = true;
  };
}
