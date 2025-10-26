{ pkgs, ... }:

{
  # Ollama service - disabled at boot to improve boot time
  # To start when needed: sudo systemctl start ollama
  services.ollama = {
    enable = false;  # Changed to false - start manually when needed
    #  acceleration = "rocm";
    #  rocmOverrideGfx = "10.3.0";  # Make sure this matches the supported version, GPU issues, is too slow on Radeon
  };
}
