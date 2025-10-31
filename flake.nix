{
  description = "Simple flake to manage my NixOS Systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.5.2";
    };

    #Always use the same nixpkgs for both system + <module>
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      nix-snapd,
      winapps,
      ...
    }@inputs:
    let
      # Import user configuration (easy to switch: just change which config file to import)
      userConfig = import ./config.nix { inherit (nixpkgs) lib; };
      
      # Optional secrets overlay (git-ignored, falls back to config.nix if not present)
      secrets = if builtins.pathExists ./secrets/user-secrets.nix 
                then import ./secrets/user-secrets.nix 
                else {};
      
      # Merge config with secrets
      finalUserConfig = userConfig // { user = userConfig.user // secrets; };
      
      # Helper function for creating system configurations
      mkSystem = import ./lib/mkSystemConfig.nix {
        inherit nixpkgs inputs;
        userConfig = finalUserConfig;
      };
    in
    {
      nixosConfigurations = {
        server = mkSystem {
          system = "x86_64-linux";
          hostname = "server";
          modules = [
            ./modules/essential/server-config.nix
            ./systems/server/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        phoenix = mkSystem {
          system = "x86_64-linux";
          hostname = "phoenix";
          modules = [
            ./systems/phoenix
            ./modules/essential/server-config.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        phoenix-arm = mkSystem {
          system = "aarch64-linux";
          hostname = "phoenix";
          modules = [
            ./systems/phoenix
            ./modules/essential/server-config.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        omnix = mkSystem {
          system = "x86_64-linux";
          hostname = "omnix";
          modules = [
            ./systems/omnix
            ./modules/addons/desktop/desktop-config.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nix-snapd.nixosModules.default
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  winapps.packages.x86_64-linux.winapps
                  winapps.packages.x86_64-linux.winapps-launcher # optional
                ];
              }
            )
          ];
        };

        blade = mkSystem {
          system = "x86_64-linux";
          hostname = "blade";
          modules = [
            ./systems/blade
            ./modules/essential/server-config.nix
            inputs.nix-snapd.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        cospi = mkSystem {
          system = "x86_64-linux";
          hostname = "cospi";
          modules = [
            ./systems/cospi
            ./modules/addons/desktop/desktop-config.nix
            inputs.nix-snapd.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ];
        };
      };

      deploy.nodes = {
        server = {
          hostname = "server"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
          };
        };

        phoenix = {
          hostname = "phoenix"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.phoenix;
          };
        };

        phoenix-arm = {
          hostname = "phoenix"; # should be same in ~/.ssh/config
          sshUser = "root"; # should be same in ~/.ssh/config
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.phoenix;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) inputs.deploy-rs.lib;
    };
}
