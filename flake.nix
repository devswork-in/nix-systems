{
  description = "Simple flake to manage my NixOS Systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.flake-compat.follows = "flake-compat";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    livewall.url = "github:Creator54/livewall/v3";

    awrit = {
      url = "github:creator54/awrit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-flatpak, nix-snapd, nur
    , nix-repo-sync, walker, elephant, livewall, awrit, ... }@inputs:
    let
      # Import user configuration (easy to switch: just change which config file to import)
      userConfig = import ./config.nix { inherit (nixpkgs) lib; };

      # NIX_CONFIG_DIR intentionally permits syncing editable worktree files.
      flakeRoot = let configuredRoot = builtins.getEnv "NIX_CONFIG_DIR";
      in if configuredRoot != "" then configuredRoot else builtins.toString self.outPath;

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
        inherit nixpkgs nixpkgs-unstable inputs flakeRoot;
        userConfig = finalUserConfig;
      };

      # Helper function for creating desktop system configurations
      mkDesktopSystem = import ./lib/mkSystemConfig.nix {
        inherit nixpkgs nixpkgs-unstable inputs flakeRoot;
        userConfig = desktopUserConfig;
      };

      phoenixVmUserConfig = finalUserConfig // {
        services = finalUserConfig.services // {
          website = finalUserConfig.services.website // { https = false; };
        };
      };

      mkPhoenixVmSystem = import ./lib/mkSystemConfig.nix {
        inherit nixpkgs nixpkgs-unstable inputs flakeRoot;
        userConfig = phoenixVmUserConfig;
      };

      phoenixModules = [
        ./hosts/phoenix
        ./modules/server/default.nix
        inputs.nix-repo-sync.nixosModules.default
      ];
    in {
      nixosConfigurations = {
        server = mkSystem {
          system = "x86_64-linux";
          hostname = "server";
          modules = [
            ./modules/server/default.nix
            ./hosts/server/configuration.nix
            # Note: No home-manager - servers use nix-repo-sync for user configs
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        # Fast local VM evaluation of the Phoenix server role.
        phoenix-x86 = mkPhoenixVmSystem {
          system = "x86_64-linux";
          hostname = "phoenix";
          modules = phoenixModules ++ [{
            services.nix-repo-sync.enable = nixpkgs.lib.mkForce false;
            virtualisation.oci-containers.containers = {
              whoogle-search.autoStart = nixpkgs.lib.mkForce false;
              leetcode.autoStart = nixpkgs.lib.mkForce false;
              planner.autoStart = nixpkgs.lib.mkForce false;
            };
          }];
        };

        phoenix-arm = mkSystem {
          system = "aarch64-linux";
          # No buildSystem = builds natively on ARM host, using binary cache
          hostname = "phoenix";
          modules = phoenixModules;
        };

        omnix = mkDesktopSystem {
          system = "x86_64-linux";
          hostname = "omnix";
          modules = [
            ./hosts/omnix/configuration.nix
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
            ./hosts/blade/configuration.nix
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
            ./hosts/cospi/configuration.nix
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
