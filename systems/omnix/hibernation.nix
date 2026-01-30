{
  boot = {
    resumeDevice = "/dev/nvme0n1p2";
    kernelParams = [ "resume_offset=4685824" ]; # sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
  };

  # Suspend-then-hibernate everywhere
  services.logind = {
    #https://wiki.archlinux.org/title/getty
    #NAutoVTs specifys no of tty's we can have
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "2min";
      PowerKeyIgnoreInhibited = "yes";
      NAutoVTs = 1;
      KillUserProcesses = true; # on logout kill all user processes
    };
  };
}
