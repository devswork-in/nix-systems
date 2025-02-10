{ config, pkgs, ... }:

let
  pname = "zen-browser";
  version = "1.7.6b";
  src = pkgs.fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
    sha256 = "sha256-GJuxooMV6h3xoYB9hA9CaF4g7JUIJ2ck5/hiQp89Y5o=";
  };

  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;
  };
in
{
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
                # Debug: List contents of extracted AppImage
                echo "Listing contents of extracted AppImage:"
                ls -la ${appimageContents}
                echo "Listing usr directory if it exists:"
                ls -la ${appimageContents}/usr || true

                # Create desktop entry and icon directories
                mkdir -p $out/share/applications
                
                # Create directories for different icon sizes
                for size in 16 32 48 64 128 256 512 1024; do
                  mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
                done

                # Create a desktop entry manually if not found
                cat > $out/share/applications/${pname}.desktop << EOF
        [Desktop Entry]
        Name=Zen Browser
        Comment=A modern and fast web browser
        Exec=${pname}
        Terminal=false
        Type=Application
        Categories=Network;WebBrowser;
        Icon=${pname}
        EOF

                # Try to find and install icons for different sizes
                for size in 16 32 48 64 128 256 512 1024; do
                  for icon in \
                    ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/zen-browser.png \
                    ${appimageContents}/icons/''${size}x''${size}.png \
                    ${appimageContents}/icons/''${size}.png; do
                    if [ -f "$icon" ]; then
                      echo "Found ''${size}x''${size} icon at: $icon"
                      install -m 444 -D "$icon" "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
                      break
                    fi
                  done
                done

                # Fallback to any available icon if no size-specific icons found
                if [ ! -f "$out/share/icons/hicolor/512x512/apps/${pname}.png" ]; then
                  for icon in \
                    ${appimageContents}/usr/share/icons/hicolor/512x512/apps/zen-browser.png \
                    ${appimageContents}/zen-browser.png \
                    ${appimageContents}/.DirIcon \
                    ${appimageContents}/icon.png; do
                    if [ -f "$icon" ]; then
                      echo "Using fallback icon from: $icon"
                      for size in 16 32 48 64 128 256 512 1024; do
                        mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
                        install -m 444 -D "$icon" "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
                      done
                      break
                    fi
                  done
                fi

                # Debug: Show final installation
                echo "Contents of $out/share/applications:"
                ls -la $out/share/applications
                echo "Installed icon sizes:"
                for size in 16 32 48 64 128 256 512 1024; do
                  if [ -f "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png" ]; then
                    echo "Found ''${size}x''${size} icon"
                  fi
                done
      '';
    })
  ];
}
