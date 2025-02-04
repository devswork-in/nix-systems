{
  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
    };

    "/home" = {
      device = "/dev/sda3";
      fsType = "ext4";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 5; # matters only when using multiple swap devices
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 5120;
    }
  ];
}
