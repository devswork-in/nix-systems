{ config, pkgs, lib, ... }:

let
  kiro = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "kiro";
    version = "202511032205";

    src = pkgs.fetchurl {
      url = "https://prod.download.desktop.kiro.dev/releases/202511032205--distro-linux-x64-tar-gz/202511032205-distro-linux-x64.tar.gz";
      hash = "sha256-Xm7uRogux3bQMsWjdaamrHELnxNltRmjPLM8Mgt5+5Y=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libdrm
      libnotify
      libsecret
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
    ];

    sourceRoot = "Kiro";

    installPhase = ''
      runHook preInstall

      # Create directory structure
      mkdir -p $out/lib/kiro
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/pixmaps

      # Copy all Kiro files
      cp -r ./* $out/lib/kiro/

      # Create wrapper script
      makeWrapper $out/lib/kiro/kiro $out/bin/kiro \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      # Install icon if it exists
      if [ -f $out/lib/kiro/resources/app/resources/linux/code.png ]; then
        cp $out/lib/kiro/resources/app/resources/linux/code.png $out/share/pixmaps/kiro.png
      elif [ -f $out/lib/kiro/kiro.png ]; then
        cp $out/lib/kiro/kiro.png $out/share/pixmaps/kiro.png
      fi

      # Create desktop entry
      cat > $out/share/applications/kiro.desktop << EOF
[Desktop Entry]
Name=Kiro
Comment=Kiro – AI-IDE for prototype to production
Exec=kiro --open-url %u
Icon=kiro
Terminal=false
Type=Application
Categories=Development;IDE;
MimeType=x-scheme-handler/kiro;
StartupWMClass=Kiro
EOF

      runHook postInstall
    '';

    meta = with lib; {
      description = "Kiro – AI-IDE for prototype to production";
      homepage = "https://kiro.so";
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "kiro";
    };
  };

in {
  environment.systemPackages = [
    kiro
  ];
}
