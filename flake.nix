{
  description = "Simple flake to manage my NixOS Systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";

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
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nur.url = "github:nix-community/NUR";
    
    nix-repo-sync = {
      url = "github:Creator54/nix-repo-sync";
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
      nur,
      nix-repo-sync,
      ...
    }@inputs:
    let
      # Extract NixOS version from nixpkgs input URL
      nixosVersion = 
        let
          # Get the nixpkgs input URL (e.g., "github:NixOS/nixpkgs/release-25.05")
          nixpkgsUrl = inputs.nixpkgs.sourceInfo.originalUrl or "release-25.05";
          # Extract version using regex match
          versionMatch = builtins.match ".*release-([0-9]+\\.[0-9]+).*" nixpkgsUrl;
        in
          if versionMatch != null
          then builtins.head versionMatch
          else "25.05"; # fallback
      
      # Import user configuration (easy to switch: just change which config file to import)
      userConfig = import ./config.nix { inherit (nixpkgs) lib; };
      
      # Get flake root dynamically using PWD environment variable
      # This requires building with --impure flag: nixos-rebuild switch --flake .#hostname --impure
      # This allows config-sync to create symlinks to the actual editable repo, not nix store
      flakeRoot = 
        let
          pwd = builtins.getEnv "PWD";
        in
          if pwd != "" then pwd
          else builtins.toString self.outPath;
      
      # Import desktop settings
      desktopSettings = import ./modules/addons/desktop/desktop-settings.nix {};
      
      # Optional secrets overlay (git-ignored, falls back to config.nix if not present)
      secrets = if builtins.pathExists ./secrets/user-secrets.nix 
                then import ./secrets/user-secrets.nix 
                else {};
      
      # Merge config with secrets
      finalUserConfig = userConfig // { 
        user = userConfig.user // secrets;
      };
      
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
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        phoenix = mkSystem {
          system = "x86_64-linux";
          hostname = "phoenix";
          modules = [
            ./systems/phoenix
            ./modules/essential/server-config.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        phoenix-arm = mkSystem {
          system = "aarch64-linux";
          hostname = "phoenix";
          modules = [
            ./systems/phoenix
            ./modules/essential/server-config.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        omnix = mkDesktopSystem {
          system = "x86_64-linux";
          hostname = "omnix";
          modules = [
            ./systems/omnix
            ./modules/addons/desktop/desktop-config.nix
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nix-snapd.nixosModules.default
            inputs.nix-repo-sync.nixosModules.default
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
            inputs.nix-repo-sync.nixosModules.default
          ];
        };

        cospi = mkDesktopSystem {
          system = "x86_64-linux";
          hostname = "cospi";
          modules = [
            ./systems/cospi
            ./modules/addons/desktop/desktop-config.nix
            inputs.nix-snapd.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
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
