{ pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.sx.enable = true; # minimal replacement for startx
      deviceSection = ''
        Option "TearFree" "true"
      '';
      excludePackages = [ pkgs.xterm ];
    };

    libinput = {
      enable =
        true; # touchpad support generally enabled by most display managers
      touchpad.naturalScrolling = true;
    };

    udev.extraRules = lib.mkMerge [
      # autosuspend USB devices
      ''
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"''
      # autosuspend PCI devices
      ''
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"''
      # disable Ethernet Wake-on-LAN
      ''
        ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"''
    ];

    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 95;
        STOP_CHARGE_THRESH_BAT0 = 100;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MAX_PERF_ON_BAT = 100;
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
      };
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";

    # No need to autologin as ony one tty is active now, works as logic screen
    #getty = {
    #  greetingLine = "";
    #  helpLine = "";
    #  autologinUser = "${uc.user}";
    #};

    #https://discourse.nixos.org/t/udiskie-no-longer-runs/23768
    udisks2.enable = true;
    thermald.enable = true;
    upower.enable = true;
    # check once using sftp via cli
    # can give issues if/won't connect if loading a non-interactive bash session is taking time
    # had direnv and startship running via bashrc due to which ssh conn in nautilus was failing 
    # and sftp on cli was failing
    gvfs.enable = true;
    preload.enable = true;
    gnome.gnome-keyring.enable =
      true; # fails to save if enabled via home-manager
    cachix-agent = {
      # needs /etc/cachix-agent.token fix to have CACHIX_AGENT_TOKEN=<CACHIX_AUTH_TOKEN>
      enable = true;
    };

    logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";
      powerKey = "suspend";

      #https://wiki.archlinux.org/title/getty
      #NAutoVTs specifys no of tty's we can have
      extraConfig = ''
        HandlePowerKey=suspend
        NAutoVTs=1
      '';
      # Kill all user-processes after logout
      killUserProcesses = true;
    };
  };

  # systemd services which i dont like/use mostly cuz increases boot time and i find no issues not having them
  #systemd.services = {
  #  systemd-udev-settle.enable = false;
  #  NetworkManager-wait-online.enable = false;
  #  firewall.enable = false;
  #  systemd-journal-flush.enable = false;
  #  lvm2-activation-early.enable = false;
  #  lvm2-activation.enable = false;
  #};

  programs = {
    ccache.enable = true;
    light.enable = true;
    nix-ld.enable =
      true; # Run unpatched dynamic binaries on NixOS., check : https://github.com/Mic92/nix-ld
  };
}

