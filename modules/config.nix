{ ... }:
let
  user="creator54";
  userDomain="devswork.in";
  userEmail = "hi.creator54@gmail.com";
  path = "/var/www/devswork.in";

  src = {
    local_site = "${path}/devswork.in";
    local_blog = "${path}/blogger/";
  };

  config = {
    hostName = userDomain;
    userName = user;
    userEmail = userEmail;
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
