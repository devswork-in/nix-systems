{ ... }:
let
  user="creator54";
  userDomain="devswork.in";
  userEmail = "hi.creator54@gmail.com";
  path = "/var/www/${userDomain}";

  src = {
    local_site = "${path}/${userDomain}";
    local_blog = "${path}/blog.${userDomain}";
  };

  config = {
    hostName = userDomain;
    userName = user;
    userEmail = userEmail;
    nixosReleaseVersion = "23.11";
    hashedPassword = "$y$j9T$xIo2r2i0pl55kKgQx0X5S1$0VtDoXgpYwcQieQ7pZ08rEhXRFHSPKgvkPw9OS4uTP3";
    sshKeys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9wiMgFixwVeBltzm9IaGtScIuuDvmfhqEShPXCvupyGfeXvKuovtHw28ZMF7C6bHCsfHZzIb71WCJFMoopIxqORW+H+Ya++UuT7kJ/vdm24qnPh4pj9wX159i7fUh3qIdL39sGYTIEFjL9zGjSYOhbx9b73W/sCREJ5NUx22HKYtKCESveWZJUiSxCmPL0MB9Xr3+IRfO0VTSteg76favRWrZ9MB2zpKAlEuUNwiqJR6Rbtc0XEVO2MmCfzdP3lfrRBPDXtx7F0tk76FnSts7jQDB6DVjWxdqRrh+jZzf3mg0nraoJ9W/H44ubOjtQGjfciANamEml0kGg2J00NrtDmzvm06M+G3H3GC7ylm8tAcz2AHZlMjRTxjLhxxSDCxGsCbLankJ0vAkqq2pmeBrCaJfcJzisblEEHKhoY1t7LUJHFboQ/XV5Bg6K8ZYMki2NAyOlO7FEOTzWE1+ZrYyqG85T9vifnVCiIAMVUR9aSXJF1Y04MkJV4o74eGPvGsRbWRLJ+wfnCkEzZgWNNEZOPiPM2eJeZFD4kn4+8aEpeavV7rVQAoWvlb2eQ1ZVsQwKghxsReJ0FjjTDA7NBxAnITsEoDnAnUdws9PfLeNTpoQ1pcv2HD3nq2LWGwd4u2Tv0cYwtjTyN6q5B7Qp6k2LV9FyMThWCjBRQyCTKT4Ww== hi.creator54@gmail.com'' ];
    path="${path}";

    hostSrc = if builtins.pathExists src.local_site then src.local_site else builtins.fetchTarball "https://github.com/creator54/creator54.me/tarball/main";
    blogSrc = if builtins.pathExists src.local_blog then src.local_blog else builtins.fetchTarball "https://github.com/creator54/blog.creator54.me/tarball/main";
    website = {
      enable = true; # enables website, blog
      https = true;
      codeServer = {
        enable = false;
        host = "code.${userDomain}";
        user = user;
        port = 5000;
      };
      nextCloud = {
        enable = false;
        adminUser = user;
        host = "cloud.${userDomain}";
      };
      adguard = {
        enable = false;
        host = "ag.${userDomain}";
        port = 3000; # set this port only in the website UI
      };
      jellyfin = {
        enable = false;
        user = user;
        host = "tv.${userDomain}";
        port = 8096; # jellyfin runs on this port by default, no option to change currently
      };
      plex = {
        enable = false;
        user = user;
        host = "plex.${userDomain}";
        dataDir = "/var/lib/plex";
        port = 32400; # plex runs on this port by default, no option to change currently
      };
      whoogle = {
        enable = false;
        host = "search.${userDomain}";
        port = "8050"; # strings allowed here
      };
    };
  };
in
config
