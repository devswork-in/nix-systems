{
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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 5; # matters only when using multiple swap devices
  };

  swapDevices = [{
    device = "/swapfile";
    size = 5120;
  }];
}
