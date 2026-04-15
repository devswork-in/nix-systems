# swiv - Simple Wayland Image Viewer
{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, wayland
, wayland-scanner
, wayland-protocols
, imlib2
, cairo
, fontconfig
, pango
, libxkbcommon
, libexif
, libpng
, libjpeg
, giflib
}:

stdenv.mkDerivation rec {
  pname = "swiv";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "ShaqeelAhmad";
    repo = "swiv";
    rev = "master";
    sha256 = "sha256-3iiazOndpl3J4UiEOlWrbDoPdSh0X/En+IzdQa7eWC4=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    imlib2
    cairo
    fontconfig
    pango
    wayland
    wayland-protocols
    libxkbcommon
    libexif
    libpng
    libjpeg
    giflib
  ];

  preConfigure = ''
    export WAYLAND_SCANNER=${wayland-scanner}/bin/wayland-scanner
    export WL_PROTOCOLS_DIR=${wayland-protocols}/share/wayland-protocols
    make config.h
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "WAYLAND_SCANNER=${wayland-scanner}/bin/wayland-scanner"
    "WL_PROTOCOLS_DIR=${wayland-protocols}/share/wayland-protocols"
  ];

  installFlags = [ "PREFIX=$(out)" ];
}