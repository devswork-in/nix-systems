{ config, pkgs, ... }:
let
  doom = pkgs.writeShellScriptBin "doom" ''${
    config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.config/emacs/bin/doom")
  } "$@"'';
in
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };

  services.emacs.enable = true;

  systemd.user.services.doom-sync = {
    Unit.Description = "Doom Emacs fetch config";
    Service = {
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '\
        DOOM="${config.home.homeDirectory}/.config/emacs";\
        if [ ! -d "$DOOM" ]; then \
          ${pkgs.git}/bin/git clone --depth=1 https://github.com/doomemacs/doomemacs.git "$DOOM" &>/dev/null && \
          echo "Cloning complete!"; \
        else \
          echo "Debug: Directory $DOOM already exists and is not empty."; \
        fi;\
        '
      '';
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.packages = with pkgs; [
    doom
    gnutls
    aspell
    aspellDicts.en
    aspellDicts.es
  ];
}
