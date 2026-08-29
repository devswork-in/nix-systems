{ pkgs, lib, config, userConfig, ... }:

let
  offsetFile = /var/lib/nixos/resume-offset;
  # Safely read file, handling missing/empty cases
  fileContent = if builtins.pathExists offsetFile then builtins.readFile offsetFile else "";
  # Remove whitespace/newlines which might break verification
  cleanContent = lib.replaceStrings ["\n" " " "\r"] ["" "" ""] fileContent;
  # Default to 0 if empty or invalid
  resumeOffset = if cleanContent == "" then 0 else lib.toInt cleanContent;
in
{
  boot = {
    resumeDevice = "/dev/nvme0n1p3";
    kernelParams = [ "resume_offset=${toString resumeOffset}" ];
    kernelModules = [ "i2c_hid_acpi" ];
  };

  # systemd-hibernate and related sleep services run inside a restricted sandbox (ProtectHome=yes) by default.
  # Since our swapfile is located in /home, we MUST relax this sandbox so systemd can read the physical offset 
  # of the swapfile. Otherwise, `systemctl hibernate` fails instantly with "No such file or directory" 
  # because /home appears completely empty to the hibernation service.
  systemd.services = {
    systemd-hibernate.serviceConfig.ProtectHome = "read-only";
    systemd-suspend-then-hibernate.serviceConfig.ProtectHome = "read-only";
    systemd-hybrid-sleep.serviceConfig.ProtectHome = "read-only";
    systemd-logind.serviceConfig.ProtectHome = "read-only";
  };

  # Suspend-then-hibernate everywhere
  services.logind = {
    #https://wiki.archlinux.org/title/getty
    #NAutoVTs specifys no of tty's we can have
    settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchDocked = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      LidSwitchIgnoreInhibited = "yes";
      HoldoffTimeoutSec = "5s"; # Allow sleep shortly after wake (default 30s)
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "2min";
      PowerKeyIgnoreInhibited = "yes";
      NAutoVTs = 1;
      KillUserProcesses = true; # on logout kill all user processes
    };
  };

  # Enable persistent logs to debug freeze/hibernate failures
  # (journal size limit set in desktop-utils/services.nix)
  services.journald.storage = "persistent";
  
  # Ensure the directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal - -"
  ];

  # Force hibernation after 15min of suspend (default is 2h or battery-based)
  # This MUST be in sleep.conf, NOT logind.conf
  systemd.sleep.settings.Sleep.HibernateDelaySec = "15min";

  # The ELAN device can disappear from ACPI if its driver remains bound while
  # firmware enters sleep. Detach before sleep, then bind after firmware wakes.
  powerManagement.powerDownCommands = ''
    ${pkgs.kmod}/bin/modprobe -r i2c_hid_acpi || true
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.coreutils}/bin/sleep 1
    ${pkgs.kmod}/bin/modprobe i2c_hid_acpi

    touchpad_path=/sys/bus/i2c/devices/i2c-ELAN06FA:00
    for _ in $(${pkgs.coreutils}/bin/seq 1 10); do
      [ -e "$touchpad_path" ] && break
      ${pkgs.coreutils}/bin/sleep 0.2
    done

    if [ ! -e "$touchpad_path" ]; then
      echo "ELAN touchpad did not return after resume" >&2
      false
    fi
  '';

  systemd.services.update-resume-offset = {
    description = "Automatically update resume-offset if swapfile offset changes";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "update-resume-offset" ''
        OFFSET_FILE="/var/lib/nixos/resume-offset"
        SWAP_FILE="${config.swap.path}"
        
        if [ ! -f "$SWAP_FILE" ]; then
          exit 0
        fi
        
        # Create directory if it doesn't exist
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$OFFSET_FILE")"
        
        # Calculate offset using absolute paths
        ACTUAL_OFFSET=$(${pkgs.e2fsprogs}/bin/filefrag -v "$SWAP_FILE" | ${pkgs.gawk}/bin/awk '{if($1=="0:"){print $4}}' | ${pkgs.gnused}/bin/sed 's/\.\.//')
        
        if [ -z "$ACTUAL_OFFSET" ]; then
            echo "Error: Failed to calculate swapfile offset"
            exit 1
        fi
        
        if [ ! -f "$OFFSET_FILE" ]; then
           # If file doesn't exist, create it and warn to rebuild
           echo "$ACTUAL_OFFSET" > "$OFFSET_FILE"
           echo "Created new resume-offset file at $OFFSET_FILE."
           echo "Please run 'nixos-rebuild switch --flake .#omnix --impure' to apply the new kernel parameter."
           ${pkgs.coreutils}/bin/chown ${userConfig.user.name}:users "$OFFSET_FILE"
           ${pkgs.coreutils}/bin/chmod 644 "$OFFSET_FILE"
           exit 0
        fi
        
        CURRENT_STORED=$(${pkgs.coreutils}/bin/cat "$OFFSET_FILE")
        
        if [ "$ACTUAL_OFFSET" != "$CURRENT_STORED" ]; then
          echo "Updating resume offset from $CURRENT_STORED to $ACTUAL_OFFSET"
          echo "$ACTUAL_OFFSET" > "$OFFSET_FILE"
          echo "WARNING: $SWAP_FILE offset has changed and resume-offset was updated."
          echo "Please run 'nixos-rebuild switch --flake .#omnix --impure' to apply the new kernel parameter."
        fi
        
        # Ensure user can read the file
        ${pkgs.coreutils}/bin/chown ${userConfig.user.name}:users "$OFFSET_FILE"
        ${pkgs.coreutils}/bin/chmod 644 "$OFFSET_FILE"
      '';
    };
  };
}
