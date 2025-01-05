{
  boot = {
    resumeDevice = "/dev/nvme0n1p2";
    kernelParams = [ "resume_offset=4685824" ]; #sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
  };


  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchDocked = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";

    #https://wiki.archlinux.org/title/getty
    #NAutoVTs specifys no of tty's we can have
    extraConfig = ''
      HandlePowerKey=hybrid-sleep
      NAutoVTs=1
    '';
  };
}
