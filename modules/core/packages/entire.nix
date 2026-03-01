{ pkgs, ... }:

let
  entire = pkgs.stdenv.mkDerivation rec {
    pname = "entire";
    version = "0.4.5";

    src = let
      arch = if pkgs.stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
    in pkgs.fetchurl {
      url = "https://github.com/entireio/cli/releases/download/v${version}/entire_linux_${arch}.tar.gz";
      sha256 = if pkgs.stdenv.hostPlatform.isAarch64
        then "sha256-rr8pKrUfHbXZdx7aOt6H97D6f2k46kkRCQuCFQM8gw4="
        else "sha256-miQ80eYAzg4hFWHc8rUXAYX9Qs4dm3LRCGzyCvAZR0U=";
    };

    sourceRoot = ".";
    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp entire $out/bin/entire
      chmod +x $out/bin/entire
    '';

    meta = {
      description = "Entire CLI - AI coding session capture for Git";
      homepage = "https://github.com/entireio/cli";
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  };
in {
  home.packages = [ entire ];
}
