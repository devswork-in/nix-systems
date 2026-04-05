# rtk - CLI proxy that reduces LLM token consumption by 60-90%
# https://github.com/rtk-ai/rtk
{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "rtk";
  version = "0.34.3";

  src = pkgs.fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-pgfBe/3MwdSNyUyoHNOlRVIzKd9qN4No/RddgCNCXqU=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp rtk $out/bin/
    chmod +x $out/bin/rtk
  '';

  meta = {
    description = "CLI proxy that reduces LLM token consumption by 60-90% on common dev commands";
    homepage = "https://github.com/rtk-ai/rtk";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
    mainProgram = "rtk";
  };
}
