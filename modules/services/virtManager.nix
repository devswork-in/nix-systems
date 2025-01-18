{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ virt-manager virt-viewer quickemu ];
  users.users.creator54.extraGroups = [ "libvirtd" ];
  virtualisation = {
    libvirtd.enable = true;
  };
}
