{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "niri-sidebar";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/Vigintillionn/niri-sidebar/releases/download/v${version}/niri-sidebar-linux-x86_64";
    sha256 = "c280bb4a56229c056925f0c2abbac60a56e8daae6bc812e629de6e2118e721d3";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/niri-sidebar
    runHook postInstall
  '';

  meta = with lib; {
    description = "A lightweight, external sidebar manager for the Niri window manager.";
    homepage = "https://github.com/Vigintillionn/niri-sidebar";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
