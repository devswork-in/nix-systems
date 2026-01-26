{ pkgs, ... }:

{
  # Zen Kernel: Optimized for desktop/gaming, usually better cached than XanMod
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
