{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
  #  acceleration = "rocm";
  #  rocmOverrideGfx = "10.3.0";  # Make sure this matches the supported version, GPU issues, is too slow on Radeon
  };
}

