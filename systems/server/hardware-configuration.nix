{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  # Use LTS kernel - best cache coverage for aarch64
  boot.kernelPackages = pkgs.linuxPackages;
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  fileSystems = {
    "/boot/efi" = {
      device = "/dev/sda15";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };

  boot.initrd = {
    availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
    ];
    kernelModules = [ "nvme" ];
  };
}
