# Helper function to create a wrapped AppImage with desktop integration
# Extracted from modules/addons/apps/appimages/default.nix

{ pkgs }:

{ pname, version, src, name ? null, comment ? null, categories ? null }:

let
  appName = if name != null then name else pname;
  appComment = if comment != null then comment else "Application ${appName}";
  appCategories = if categories != null then categories else "Application";
  
  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;
  };
in pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  binName = pname; # Explicitly set the executable name to match pname for consistency

  extraInstallCommands = ''
    # Create desktop entry and icon directories
    mkdir -p $out/share/applications

    # Create directories for different icon sizes
    for size in 16 32 48 64 128 256 512 1024; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
    done

    # Create a desktop entry
    cat > $out/share/applications/${pname}.desktop << EOF
[Desktop Entry]
Name=${appName}
Comment=${appComment}
Exec=${pname}
Terminal=false
Type=Application
Categories=${appCategories}
Icon=${pname}
EOF

    # Try to find and install icons for different sizes
    for size in 16 32 48 64 128 256 512 1024; do
      for icon in \
        ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png \
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
        ${appimageContents}/usr/share/icons/hicolor/512x512/apps/${pname}.png \
        ${appimageContents}/${pname}.png \
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
  '';
}
