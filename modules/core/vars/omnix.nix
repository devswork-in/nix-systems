{ config, pkgs, ... }: {
  environment.variables = {
    # VA-API driver for video acceleration (hardware decode/encode)
    LIBVA_DRIVER_NAME = "radeonsi";

    # Force RADV over AMDVLK if both are present (RADV is better for modern cards)
    AMD_VULKAN_ICD = "RADV";
  };
}
