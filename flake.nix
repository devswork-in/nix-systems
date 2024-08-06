{
  description = "Simple flake to manage my NixOS Systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    };

    #Always use the same nixpkgs for both system + <module>
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
	  ./modules/configs/minimal
          ./systems/server/configuration.nix
        ];
      };

      phoenix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./systems/phoenix
	  ./modules/configs/minimal
          inputs.home-manager.nixosModules.default
        ];
      };

      blade = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./systems/blade
	  ./modules/configs/minimal
          inputs.nix-snapd.nixosModules.default
          inputs.home-manager.nixosModules.default
	  inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
      };
      cospi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./systems/cospi
	  ./modules/configs/full
          inputs.nix-snapd.nixosModules.default
          inputs.home-manager.nixosModules.default
	  inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };

    deploy.nodes = {
      server = {
        hostname = "server"; #should be same in ~/.ssh/config
        sshUser = "root"; #should be same in ~/.ssh/config
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
        };
      };

      phoenix = {
        hostname = "phoenix"; #should be same in ~/.ssh/config
        sshUser = "root"; #should be same in ~/.ssh/config
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.phoenix;
        };
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
