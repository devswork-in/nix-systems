# Desktop-specific packages that build on common packages
{ pkgs, ... }:

{
  imports = [
    ../../core/packages # Import common packages
  ];

  # Add only desktop-specific packages
  home.packages = with pkgs; [
    # amp-cli
    bc
    openssl
    # koji
    nodejs
    (pre-commit.override {
      dotnet-sdk = pkgs.writeShellScriptBin "dotnet" "echo 'fake dotnet SDK for pre-commit override'";
    })
    vlc
    telegram-desktop
    ncftp
    comma
    capitaine-cursors
    fortune
    file
    nautilus
    go
    xcolor
    kitty
    # remmina
    # jmeter
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
    libnotify
    ntfs3g
    android-tools
    efibootmgr
    websocat
    xdotool # Required for fusuma touchpad gestures
    # (kodi.withPackages
    #   (p: with p; [ inputstream-adaptive pvr-iptvsimple inputstreamhelper ]))
    #ref https://discourse.nixos.org/t/google-chrome-not-working-after-recent-nixos-rebuild/43746/8
    google-chrome

    # Polkit authentication agent
    pantheon.pantheon-agent-polkit
  ];
}
