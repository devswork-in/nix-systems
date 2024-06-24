{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/sda15";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };

  boot.initrd = {
    availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
    kernelModules = [ "nvme" ];
  };
}
