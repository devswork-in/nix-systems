function update
  nix-channel --update nixpkgs
  nix-env -u '*'
end
