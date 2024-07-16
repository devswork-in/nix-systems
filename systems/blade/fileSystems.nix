{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/df4e12d1-ce05-4218-a103-fcaabddb01ab";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7EE7-7EF9";
      fsType = "vfat";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/b204f710-41af-41df-ac9d-3fd38147e0f3";
      fsType = "ext4";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 5; #matters only when using multiple swap devices
  };

  swapDevices = [ { device = "/swapfile"; size = 20480; } ];
}
