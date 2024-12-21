{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        sha256 = "sha256-XrRwb4mPUIgVUv9RRtiSEy0//FKYAzv/4nCH06RMRXM=";
      };
      version = "6.1.103";
      modDirVersion = "6.1.103";
    };
  });
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
