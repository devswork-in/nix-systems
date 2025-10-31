# Desktop-specific packages that build on common packages
{ pkgs, ... }:

{
  imports = [
    ../common  # Import common packages
    ../../configs/desktop  # Import desktop configs
  ];

  # Add only desktop-specific packages
  home.packages = with pkgs; [
    bc
    openssl
    xplr
    koji
    nodejs
    pre-commit
    vlc
    tdesktop
    ncftp
    comma
    postman
    capitaine-cursors
    fortune
    file
    nautilus
    go
    xcolor
    kitty
    remmina
    jmeter
    yt-dlp
    ueberzug
    qbittorrent
    picom
    cmus
    oci-cli
    conky
    gromit-mpx
    pup
    nixos-option
    screenkey
    android-tools
    efibootmgr
    websocat
    (kodi.withPackages (
      p: with p; [
        inputstream-adaptive
        pvr-iptvsimple
        inputstreamhelper
      ]
    ))
    #ref https://discourse.nixos.org/t/google-chrome-not-working-after-recent-nixos-rebuild/43746/8
    google-chrome
  ];
}
