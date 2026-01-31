{ lib }:

let
  # User configuration
  user = {
    name = "creator54";
    domain = "devswork.in";
    email = "hi.creator54@gmail.com";
    hashedPassword = "$y$j9T$xIo2r2i0pl55kKgQx0X5S1$0VtDoXgpYwcQieQ7pZ08rEhXRFHSPKgvkPw9OS4uTP3";
    sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpDUPDzTiFLj0amSbBrAk06A2KoCgSXTlxy3p38WYjmlkkjUB7SRIknZ2uK6WJcfjdqdu6rSmMnIgIM4HRB+t0+CQEnjhUdSKGQ2X2k5vfmU9TjHJvxYya5ggP8CLCtpnxY2iEkP/gkhGxZ5g0p3+Z2qye0xRarfkEQigWC2V1jLR1IueMGdrcUBlECS+dZZcNBnjFxgtnB6qSUyZNYG+RpnnF9VYeRG+IT1HOGPExXXEjAcd1mr7Qr6l2SWMKI3ZAmDizjMHqvZvst9CV/x1pqaYiT9qg2XPbu4JprFnfege0d0vKnggAMymt3BP401so7Gen1hc32obAaC2MpGNiKMbmmErR15OesSliN3pJ+fv97Ty8VTqokysiMq78FCBnBNmulgpMTFHjUiRr5J7wFwSjJ0CTqW5X6wnRgwAUT8vIBi6J6RcepgMIMwiwPbWJECC64hrrUql4nsc3zPF/kP9JXY9c4jAMXhK88bRCaOx1HoDQcS0urOnYCRNY01HuDvW0pTg6nmqzz6zTZxIdED+lIs/kJldQAbOcOEKDawVcm4FGxAE17e3JXzPE7hM9COXHudz0NUviYMDKCIdM0IjnyTX/xcLzJErbOKp/Ds+o0PoTOonqJtVCn8t03blbw2sziG6YCgJOmL34Ahw8uqsKEys47WCZqsua0LV9iQ== creator54@omnix"
    ];
  };

  # Paths configuration
  paths = {
    base = "/var/www/${user.domain}";
  };
  
  # Import sync configuration
  syncConfig = import ./sync-config.nix { inherit user paths; };

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

in
{
  inherit user paths services syncConfig;
}
