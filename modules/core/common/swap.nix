# Common swap and memory configurations for all systems
{ ... }: {

  # Common zram swap configuration
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 5; # matters only when using multiple swap devices
  };

  # Common swap file configuration
  swapDevices = [
    {
      device = "/swapfile";
      size = 5120;  # 5GB swap file
    }
  ];
}