{ pkgs, ... }:

let
  monocle = pkgs.buildGoModule {
    pname = "monocle";
    version = "0.46.1";

    src = pkgs.fetchFromGitHub {
      owner = "josephschmitt";
      repo = "monocle";
      rev = "v0.46.1";
      sha256 = "sha256-2ye2Y/yrJXebGX++B8ILDhZpsm4NxZ5RRRDI/dzfOpY=";
    };

    vendorHash = "sha256-oajKuhbP+DRXefoJbrOVoyE1rOdtZaPS4c3u0HUP4Kc=";

    subPackages = [ "cmd/monocle" ];

    nativeCheckInputs = [ pkgs.git ];

    ldflags = [ "-X main.version=v0.46.1" ];

    meta = with pkgs.lib; {
      description = "Review your AI agent's code as it writes it";
      homepage = "https://github.com/josephschmitt/monocle";
      license = licenses.mit;
      maintainers = [ ];
    };
  };
in
{
  home.packages = [ monocle ];
}
