{ ... }:

let
  # User configuration
  user = {
    name = "creator54";
    domain = "devswork.in";
    email = "hi.creator54@gmail.com";
    hashedPassword = "$y$j9T$xIo2r2i0pl55kKgQx0X5S1$0VtDoXgpYwcQieQ7pZ08rEhXRFHSPKgvkPw9OS4uTP3";
    sshKeys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9wiMgFixwVeBltzm9IaGtScIuuDvmfhqEShPXCvupyGfeXvKuovtHw28ZMF7C6bHCsfHZzIb71WCJFMoopIxqORW+H+Ya++UuT7kJ/vdm24qnPh4pj9wX159i7fUh3qIdL39sGYTIEFjL9zGjSYOhbx9b73W/sCREJ5NUx22HKYtKCESveWZJUiSxCmPL0MB9Xr3+IRfO0VTSteg76favRWrZ9MB2zpKAlEuUNwiqJR6Rbtc0XEVO2MmCfzdP3lfrRBPDXtx7F0tk76FnSts7jQDB6DVjWxdqRrh+jZzf3mg0nraoJ9W/H44ubOjtQGjfciANamEml0kGg2J00NrtDmzvm06M+G3H3GC7ylm8tAcz2AHZlMjRTxjLhxxSDCxGsCbLankJ0vAkqq2pmeBrCaJfcJzisblEEHKhoY1t7LUJHFboQ/XV5Bg6K8ZYMki2NAyOlO7FEOTzWE1+ZrYyqG85T9vifnVCiIAMVUR9aSXJF1Y04MkJV4o74eGPvGsRbWRLJ+wfnCkEzZgWNNEZOPiPM2eJeZFD4kn4+8aEpeavV7rVQAoWvlb2eQ1ZVsQwKghxsReJ0FjjTDA7NBxAnITsEoDnAnUdws9PfLeNTpoQ1pcv2HD3nq2LWGwd4u2Tv0cYwtjTyN6q5B7Qp6k2LV9FyMThWCjBRQyCTKT4Ww== hi.creator54@gmail.com'' ];
  };

  # Paths configuration
  paths = {
    base = "/var/www/${user.domain}";
  };

  syncRepos = {
    hostSrc = {
      url = "https://github.com/creator54/creator54.me";
      localPath = "${paths.base}/${user.domain}";
    };
    blogSrc = {
      url = "https://github.com/creator54/blog.creator54.me";
      localPath = "${paths.base}/blog.${user.domain}";
    };
    nvimSrc = {
      url = "https://github.com/creator54/starter";
      localPath = "/home/${user.name}/.config/nvim";
    };
  };

  # Website services configuration
  services = {
    website = {
      enable = true;
      https = true;
    };

    codeServer = {
      enable = false;
      host = "code.${user.domain}";
      user = user.name;
      port = 5000;
    };

    nextCloud = {
      enable = false;
      adminUser = user.name;
      host = "cloud.${user.domain}";
    };

    adguard = {
      enable = false;
      host = "ag.${user.domain}";
      port = 3000;
    };

    jellyfin = {
      enable = false;
      user = user.name;
      host = "tv.${user.domain}";
      port = 8096;
    };

    plex = {
      enable = false;
      user = user.name;
      host = "plex.${user.domain}";
      dataDir = "/var/lib/plex";
      port = 32400;
    };

    whoogle = {
      enable = true;
      host = "search.${user.domain}";
      port = "8050";
    };
  };

  # Main configuration
  config = {
    hostName = user.domain;
    userName = user.name;
    userEmail = user.email;
    nixosReleaseVersion = "24.05";
    hashedPassword = user.hashedPassword;
    sshKeys = user.sshKeys;
    path = paths.base;
    syncRepos = syncRepos;
    website = services.website;
    watchman = services.watchman;
    codeServer = services.codeServer;
    nextCloud = services.nextCloud;
    adguard = services.adguard;
    jellyfin = services.jellyfin;
    plex = services.plex;
    whoogle = services.whoogle;
  };
in
config
