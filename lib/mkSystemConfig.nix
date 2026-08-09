# Helper function to create NixOS system configurations
# Simplifies system creation in flake.nix by providing consistent structure
# Supports cross-compilation when buildSystem differs from target system

{ nixpkgs, nixpkgs-unstable, inputs, userConfig, flakeRoot }:

{ system, modules, hostname, buildSystem ? null }:

let
  # Determine if we're cross-compiling
  isCross = buildSystem != null && buildSystem != system;
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs userConfig flakeRoot;
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  # Use nixpkgs.hostPlatform instead of deprecated system parameter
  modules = [
    {
      options.nixSystems.role = nixpkgs.lib.mkOption {
        type = nixpkgs.lib.types.enum [ "desktop" "server" ];
        description = "The machine role used for role-wide configuration.";
      };
    }
    # Set hostname with mkDefault to allow system-specific override
    {
      networking.hostName = nixpkgs.lib.mkDefault hostname;
    }
    # Set the target platform (replaces deprecated 'system' parameter)
    {
      nixpkgs.hostPlatform = system;
    }
    # Global nixpkgs config
    {
      nixpkgs.config.allowUnfree = true;
    }
    # Cross-compilation settings when buildSystem is specified
    (nixpkgs.lib.mkIf isCross {
      nixpkgs.buildPlatform = buildSystem;
    })
  ] ++ modules;
}
