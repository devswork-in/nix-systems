{ pkgs,... }:

let
  blockchain = pkgs.stdenv.mkDerivation {
    pname = "adi1090x-plymouth";
    version = "0.0.1";
    src = builtins.fetchurl {
      url = "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_1/blockchain.tar.gz";
      sha256 = "sha256:1f60nvrk506bqw47g90wzbvn3bp5h1gbi0ll5f3bd6wj77qfk05i";
    };

    configurePhase = ''
      mkdir -p $out/share/plymouth/themes/
    '';

    buildPhase = ''
      tar -xvzf $src
    '';

    installPhase = ''
      cp -r blockchain $out/share/plymouth/themes
      cat blockchain/blockchain.plymouth | sed  "s@\/usr\/@$out\/@" > $out/share/plymouth/themes/blockchain/blockchain.plymouth
    '';
  };
in
{
  boot = {
    kernelParams = [ "quiet" "loglevel=3" "systemd.show_status=false" "rd.systemd.show_status=false" "rd.udev.log_level=3" "splash" "vga=current" "udev.log_priority=3" "fbcon=nodefer" ];
    consoleLogLevel = 0;
    plymouth = {
      enable = true;
      themePackages = [ blockchain ];
      theme = "blockchain";
    };
    initrd.verbose = false;
  };
}
