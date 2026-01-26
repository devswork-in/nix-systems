{
  description = "Simple flake to manage my NixOS Systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";

    flake-compat.url = "github:edolstra/flake-compat";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    nix-flatpak = { url = "github:gmodena/nix-flatpak/?ref=v0.5.2"; };

    #Always use the same nixpkgs for both system + <module>
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-repo-sync = {
      url = "github:Creator54/nix-repo-sync";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = { url = "github:vicinaehq/vicinae"; };
  };

  outputs = { self, nixpkgs, nix-flatpak, nix-snapd, nur, nix-repo-sync
    , vicinae, ... }@inputs:
    let
      # Extract NixOS version from nixpkgs input URL
      nixosVersion = let
        # Get the nixpkgs input URL (e.g., "github:NixOS/nixpkgs/release-25.05")
        nixpkgsUrl = inputs.nixpkgs.sourceInfo.originalUrl or "release-25.05";
        # Extract version using regex match
        versionMatch =
          builtins.match ".*release-([0-9]+\\.[0-9]+).*" nixpkgsUrl;
      in if versionMatch != null then
        builtins.head versionMatch
      else
        "25.05"; # fallback

      # Import user configuration (easy to switch: just change which config file to import)
      userConfig = import ./config.nix { inherit (nixpkgs) lib; };

      # Get flake root dynamically
      # Priority: NIX_CONFIG_DIR > PWD > self.outPath
      flakeRoot = let
        nixConfigDir = builtins.getEnv "NIX_CONFIG_DIR";
        pwd = builtins.getEnv "PWD";
      in if nixConfigDir != "" then
        nixConfigDir
      else if pwd != "" then
        pwd
      else
        builtins.toString self.outPath;

      # Import desktop settings
      desktopSettings = import ./modules/desktop-utils/desktop-settings.nix { };

      # Optional secrets overlay (git-ignored, falls back to config.nix if not present)
      secrets = if builtins.pathExists ./secrets/user-secrets.nix then
        import ./secrets/user-secrets.nix
      else
        { };

      # Merge config with secrets
      finalUserConfig = userConfig // { user = userConfig.user // secrets; };

      # Merge desktop settings for desktop systems
      desktopUserConfig = finalUserConfig // desktopSettings;

      # Helper function for creating system configurations
      mkSystem = import ./lib/mkSystemConfig.nix {
        inherit nixpkgs inputs nixosVersion flakeRoot;
        userConfig = finalUserConfig;
      };

      # Helper function for creating desktop system configurations
      mkDesktopSystem = import ./lib/mkSystemConfig.nix {
        inherit nixpkgs inputs nixosVersion flakeRoot;
        userConfig = desktopUserConfig;
      };
    in {
      nixosConfigurations = {
        server = mkSystem {
          system = "x86_64-linux";
          hostname = "server";
          modules = [
            ./modules/server/default.nix
            ./systems/server/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        # Helper for Phoenix (Oracle Cloud) systems
        phoenix = let
          mkPhoenix = system:
            mkSystem {
              inherit system;
              hostname = "phoenix";
              modules = [
                ./systems/phoenix
                ./modules/server/default.nix
                inputs.home-manager.nixosModules.default
                inputs.nix-repo-sync.nixosModules.default
              ];
            };
        in mkPhoenix "x86_64-linux";

        phoenix-arm = let
          mkPhoenix = system:
            mkSystem {
              inherit system;
              hostname = "phoenix";
              modules = [
                ./systems/phoenix
                ./modules/server/default.nix
                inputs.home-manager.nixosModules.default
                inputs.nix-repo-sync.nixosModules.default
              ];
            };
        in mkPhoenix "aarch64-linux";

        omnix = mkDesktopSystem {
          system = "x86_64-linux";
          hostname = "omnix";
          modules = [
            ./systems/omnix
            ./modules/desktop-utils/default.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-snapd.nixosModules.default
            nix-repo-sync.nixosModules.default
          ];
        };

        blade = mkSystem {
          system = "x86_64-linux";
          hostname = "blade";
          modules = [
            ./systems/blade
            ./modules/server/default.nix
            inputs.nix-snapd.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        cospi = mkDesktopSystem {
          system = "x86_64-linux";
          hostname = "cospi";
          modules = [
            ./systems/cospi
            ./modules/desktop-utils/default.nix
            inputs.nix-snapd.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
          ];
        };
      };

      deploy.nodes = {
        server = {
          hostname = "server"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.server;
          };
        };

        phoenix = {
          hostname = "phoenix"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.phoenix;
          };
        };

        phoenix-arm = {
          hostname = "phoenix"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos
              self.nixosConfigurations.phoenix-arm;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib;
    };
}
