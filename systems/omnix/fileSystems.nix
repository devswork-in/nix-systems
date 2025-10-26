{
  imports = [
    ../../modules/essential/common/swap.nix
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/home" = {
      device = "/dev/nvme0n1p3";
      fsType = "ext4";
    };
  };
}
