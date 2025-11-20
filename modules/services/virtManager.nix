{ pkgs, userConfig, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    quickemu
  ];
  users.users."${userConfig.user.name}".extraGroups = [ "libvirtd" ];
  virtualisation = {
    libvirtd.enable = true;
  };
}
