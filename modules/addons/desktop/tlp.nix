{ pkgs, ... }:

{
  # Enable TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings - use schedutil for AMD with amd_pstate driver
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      
      # AMD P-State EPP (Energy Performance Preference) for amd_pstate=active
      # Valid values: performance, balance_performance, default, balance_power, power
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # CPU frequency scaling (in kHz)
      CPU_SCALING_MIN_FREQ_ON_AC = 400000;
      CPU_SCALING_MAX_FREQ_ON_AC = 5100000;
      CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 3000000;
      
      # CPU turbo boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # AMD GPU power management
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
      
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      
      RADEON_POWER_PROFILE_ON_AC = "default";
      RADEON_POWER_PROFILE_ON_BAT = "low";
      
      # Platform profile (for AMD)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      
      # Runtime power management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 0;
      USB_EXCLUDE_PHONE = 0;
      USB_EXCLUDE_PRINTER = 1;
      USB_EXCLUDE_WWAN = 0;
      
      # SATA link power management
      SATA_LINKPWR_ON_AC = "max_performance";
      SATA_LINKPWR_ON_BAT = "min_power";
      
      # PCIe Active State Power Management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # Disable wake on LAN
      WOL_DISABLE = "Y";
      
      # Battery charge thresholds (helps preserve battery health)
      START_CHARGE_THRESH_BAT0 = 95;
      # STOP_CHARGE_THRESH_BAT0 = 80;
      
      # Disk settings
      DISK_IDLE_SECS_ON_AC = 0;
      DISK_IDLE_SECS_ON_BAT = 2;
      
      # Sound power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };
  
  # Disable conflicting services
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false;
  
  # Power management tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    lm_sensors
  ];
  
  # Laptop mode for better battery life
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # Additional optimizations
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.laptop_mode" = 5;
  };
}
