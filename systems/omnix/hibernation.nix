{
  boot = {
    resumeDevice = "/dev/nvme0n1p2";
    kernelParams = [ "resume_offset=4685824" ]; #sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
  };


  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    lidSwitchExternalPower = "suspend";
    powerKey = "suspend";

    #https://wiki.archlinux.org/title/getty
    #NAutoVTs specifys no of tty's we can have
    extraConfig = ''
      IdleAction=suspend
      IdleActionSec=2min
      HandlePowerKey=suspend
      PowerKeyIgnoreInhibited=yes
      NAutoVTs=1
    '';
    killUserProcesses = true; #on logout kill all user processes
  };
}
