{ config, pkgs, lib, ... }:

let
  kiro = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "kiro";
    version = "0.6.0";

    src = pkgs.fetchurl {
      url = "https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/0.6.0/tar/kiro-ide-0.6.0-stable-linux-x64.tar.gz";
      hash = "sha256-FOMfF/rJIzBnAqR5dxUlcDaMV2I/7dWMqU2UtMvJZIo=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      copyDesktopItems
      # Critical: wrapGAppsHook3 for proper desktop integration
      (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
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

    runtimeDependencies = with pkgs; [
      systemd
      fontconfig.lib
      libdbusmenu
      wayland
      libsecret
    ];

    sourceRoot = "Kiro";

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "kiro";
        desktopName = "Kiro";
        comment = "Kiro – AI-IDE for prototype to production";
        genericName = "Text Editor";
        exec = "kiro %U";
        icon = "kiro";
        startupNotify = true;
        startupWMClass = "Kiro";
        categories = [ "Utility" "TextEditor" "Development" "IDE" ];
        keywords = [ "kiro" "ide" "editor" ];
        mimeTypes = [ "x-scheme-handler/kiro" ];
        actions.new-empty-window = {
          name = "New Empty Window";
          exec = "kiro --new-window %F";
          icon = "kiro";
        };
      })
      (pkgs.makeDesktopItem {
        name = "kiro-url-handler";
        desktopName = "Kiro - URL Handler";
        comment = "Kiro – AI-IDE for prototype to production";
        genericName = "Text Editor";
        exec = "kiro --open-url %U";
        icon = "kiro";
        startupNotify = true;
        startupWMClass = "Kiro";
        categories = [ "Utility" "TextEditor" "Development" "IDE" ];
        mimeTypes = [ "x-scheme-handler/kiro" ];
        keywords = [ "kiro" ];
        noDisplay = true;
      })
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      # Create directory structure
      mkdir -p $out/lib/kiro
      mkdir -p $out/bin
      mkdir -p $out/share/pixmaps

      # Copy all Kiro files
      cp -r ./* $out/lib/kiro/

      # Create symlink to executable (will be wrapped by wrapGAppsHook3)
      ln -s $out/lib/kiro/kiro $out/bin/kiro

      # Install icon if it exists
      if [ -f $out/lib/kiro/resources/app/resources/linux/code.png ]; then
        cp $out/lib/kiro/resources/app/resources/linux/code.png $out/share/pixmaps/kiro.png
      elif [ -f $out/lib/kiro/kiro.png ]; then
        cp $out/lib/kiro/kiro.png $out/share/pixmaps/kiro.png
      fi

      runHook postInstall
    '';

    # Critical preFixup phase - this is where we set up PATH and environment
    preFixup = ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.libdbusmenu ]}
        --prefix PATH : ${lib.makeBinPath [
          pkgs.glib
          pkgs.gnugrep
          pkgs.coreutils
          pkgs.xdg-utils
        ]}
        --set BROWSER "firefox"
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
      )
    '';

    # Patch ELF to add GL libraries (critical for Electron apps)
    postFixup = ''
      patchelf \
        --add-needed ${pkgs.libglvnd}/lib/libGLESv2.so.2 \
        --add-needed ${pkgs.libglvnd}/lib/libGL.so.1 \
        --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 \
        $out/lib/kiro/kiro
    '';

    meta = with lib; {
      description = "Kiro – AI-IDE for prototype to production";
      homepage = "https://kiro.dev";
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

  # Ensure XDG desktop portal is enabled for proper URL handling
  xdg.portal.enable = lib.mkDefault true;
}
