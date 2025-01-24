{
  boot = {
    resumeDevice = "/dev/nvme0n1p2";
    kernelParams = [ "resume_offset=4685824" ]; #sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
  };


  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "hybrid-sleep";
    lidSwitchExternalPower = "hybrid-sleep";
    powerKey = "hybrid-sleep";

    #https://wiki.archlinux.org/title/getty
    #NAutoVTs specifys no of tty's we can have
    extraConfig = ''
      IdleAction=hybrid-sleep
      IdleActionSec=2min
      HandlePowerKey=hybrid-sleep
      PowerKeyIgnoreInhibited=yes
      NAutoVTs=1
    '';
    killUserProcesses = true; #on logout kill all user processes
  };
}
