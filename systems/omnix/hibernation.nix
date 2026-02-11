{ pkgs, lib, ... }:

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
    resumeDevice = "/dev/nvme0n1p2";
    kernelParams = [ "resume_offset=${toString resumeOffset}" ];
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
  services.journald.extraConfig = "Storage=persistent";
  
  # Ensure the directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/log/journal 2755 root systemd-journal - -"
  ];

  # Force hibernation after 15min of suspend (default is 2h or battery-based)
  # This MUST be in sleep.conf, NOT logind.conf
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15min
  '';

  systemd.services.update-resume-offset = {
    description = "Automatically update resume-offset if swapfile offset changes";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Add necessary tools to PATH
      Path = with pkgs; [ gawk gnused coreutils ];
      ExecStart = pkgs.writeShellScript "update-resume-offset" ''
        OFFSET_FILE="/var/lib/nixos/resume-offset"
        
        if [ ! -f /swapfile ]; then
          exit 0
        fi
        
        # Create directory if it doesn't exist
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$OFFSET_FILE")"
        
        # Calculate offset using absolute paths
        ACTUAL_OFFSET=$(${pkgs.e2fsprogs}/bin/filefrag -v /swapfile | ${pkgs.gawk}/bin/awk '{if($1=="0:"){print $4}}' | ${pkgs.gnused}/bin/sed 's/\.\.//')
        
        if [ -z "$ACTUAL_OFFSET" ]; then
            echo "Error: Failed to calculate swapfile offset"
            exit 1
        fi
        
        if [ ! -f "$OFFSET_FILE" ]; then
           # If file doesn't exist, create it and warn to rebuild
           echo "$ACTUAL_OFFSET" > "$OFFSET_FILE"
           echo "Created new resume-offset file at $OFFSET_FILE."
           echo "Please run 'nixos-rebuild switch --flake .#omnix --impure' to apply the new kernel parameter."
           ${pkgs.coreutils}/bin/chown 1000:100 "$OFFSET_FILE"
           ${pkgs.coreutils}/bin/chmod 644 "$OFFSET_FILE"
           exit 0
        fi
        
        CURRENT_STORED=$(${pkgs.coreutils}/bin/cat "$OFFSET_FILE")
        
        if [ "$ACTUAL_OFFSET" != "$CURRENT_STORED" ]; then
          echo "Updating resume offset from $CURRENT_STORED to $ACTUAL_OFFSET"
          echo "$ACTUAL_OFFSET" > "$OFFSET_FILE"
          echo "WARNING: /swapfile offset has changed and resume-offset was updated."
          echo "Please run 'nixos-rebuild switch --flake .#omnix --impure' to apply the new kernel parameter."
        fi
        
        # Ensure user can read the file
        ${pkgs.coreutils}/bin/chown 1000:100 "$OFFSET_FILE"
        ${pkgs.coreutils}/bin/chmod 644 "$OFFSET_FILE"
      '';
    };
  };
}
