{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "ollama-rocm";
  version = "0.20.2";

  src = pkgs.fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-amd64.tar.zst";
    sha256 = "0lb28aqgy83z1s2wq6l9xgz6iyal88yq51x9w66fbpi9l6n7m2d9";
  };

  rocmSrc = pkgs.fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-amd64-rocm.tar.zst";
    sha256 = "1i51dwvj8hp2qs0z09mgj84b21b9l0pnnr2sbivngr258aihdyv9";
  };

  nativeBuildInputs = [ pkgs.zstd ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/ollama

    # Extract main binary
    tar -xf $src -C $out bin/ollama
    chmod +x $out/bin/ollama

    # Extract ROCm libraries
    tar -xf $rocmSrc -C $out/lib/ollama

    runHook postInstall
  '';

  meta = {
    description = "Get up and running with LLMs locally (ROCm pre-built binary)";
    homepage = "https://ollama.com";
    license = pkgs.lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ollama";
  };
}
