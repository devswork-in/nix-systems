function upgrade
  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  sudo nixos-rebuild switch --upgrade
end
