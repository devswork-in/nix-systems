{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "infra";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9wiMgFixwVeBltzm9IaGtScIuuDvmfhqEShPXCvupyGfeXvKuovtHw28ZMF7C6bHCsfHZzIb71WCJFMoopIxqORW+H+Ya++UuT7kJ/vdm24qnPh4pj9wX159i7fUh3qIdL39sGYTIEFjL9zGjSYOhbx9b73W/sCREJ5NUx22HKYtKCESveWZJUiSxCmPL0MB9Xr3+IRfO0VTSteg76favRWrZ9MB2zpKAlEuUNwiqJR6Rbtc0XEVO2MmCfzdP3lfrRBPDXtx7F0tk76FnSts7jQDB6DVjWxdqRrh+jZzf3mg0nraoJ9W/H44ubOjtQGjfciANamEml0kGg2J00NrtDmzvm06M+G3H3GC7ylm8tAcz2AHZlMjRTxjLhxxSDCxGsCbLankJ0vAkqq2pmeBrCaJfcJzisblEEHKhoY1t7LUJHFboQ/XV5Bg6K8ZYMki2NAyOlO7FEOTzWE1+ZrYyqG85T9vifnVCiIAMVUR9aSXJF1Y04MkJV4o74eGPvGsRbWRLJ+wfnCkEzZgWNNEZOPiPM2eJeZFD4kn4+8aEpeavV7rVQAoWvlb2eQ1ZVsQwKghxsReJ0FjjTDA7NBxAnITsEoDnAnUdws9PfLeNTpoQ1pcv2HD3nq2LWGwd4u2Tv0cYwtjTyN6q5B7Qp6k2LV9FyMThWCjBRQyCTKT4Ww== hi.creator54@gmail.com'' ];
  system.stateVersion = "23.11";
}
