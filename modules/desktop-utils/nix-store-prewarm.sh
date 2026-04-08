sleep @@DELAY@@
echo "nix-store-prewarm: Starting store pre-warm..."

# Package store paths to warm (injected by Nix module)
PKG_PATHS="@@PKG_PATHS@@"

for pkg_dir in $PKG_PATHS; do
  @@NIX@@/bin/nix-store -qR "$pkg_dir" 2>/dev/null | while read -r storepath; do
    if [ -d "$storepath" ]; then
      @@FINDUTILS@@/bin/find "$storepath" -type f -size -@@MAX_SIZE_MB@@M -exec @@COREUTILS@@/bin/cat {} + > /dev/null 2>&1 || true
    fi
  done
done

echo "nix-store-prewarm: Done"
