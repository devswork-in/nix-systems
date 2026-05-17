# Common swap and memory configurations for all systems
{ config, lib, ... }: {

  options.swap = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "/home/.swapfile";
      description = "Path to the physical swap file";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 4096;
      description = "Size of the swap file in MB";
    };
  };

  config = {
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
        device = config.swap.path;
        size = config.swap.size;
      }
    ];
  };
}