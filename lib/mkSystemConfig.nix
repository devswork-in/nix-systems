# Helper function to create NixOS system configurations
# Simplifies system creation in flake.nix by providing consistent structure
# Supports cross-compilation when buildSystem differs from target system

{ nixpkgs, nixpkgs-unstable, inputs, userConfig, nixosVersion, flakeRoot }:

{ system, modules, hostname, buildSystem ? null }:

let
  # Determine if we're cross-compiling
  isCross = buildSystem != null && buildSystem != system;
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs userConfig nixosVersion flakeRoot;
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  # Use nixpkgs.hostPlatform instead of deprecated system parameter
  modules = [
    # Set hostname with mkDefault to allow system-specific override
    {
      networking.hostName = nixpkgs.lib.mkDefault hostname;
    }
    # Set the target platform (replaces deprecated 'system' parameter)
    {
      nixpkgs.hostPlatform = system;
    }
    # Global nixpkgs config - allow unfree and insecure packages
    {
      nixpkgs.config = {
        allowUnfree = true;
        allowInsecurePredicate = _: true;
      };
    }
    # Cross-compilation settings when buildSystem is specified
    (nixpkgs.lib.mkIf isCross {
      nixpkgs.buildPlatform = buildSystem;
    })
  ] ++ modules;
}

