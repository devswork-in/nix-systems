# Helper function to create NixOS system configurations
# Simplifies system creation in flake.nix by providing consistent structure

{ nixpkgs, inputs, userConfig }:

{ system, modules, hostname }:

nixpkgs.lib.nixosSystem {
  specialArgs = { 
    inherit inputs userConfig; 
  };
  inherit system;
  modules = [
    # Set hostname with mkDefault to allow system-specific override
    { networking.hostName = nixpkgs.lib.mkDefault hostname; }
  ] ++ modules;
}
