{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    personal-website = {
      url = "git+ssh://git@github.com/claby2/claby2.github.io.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, agenix, ... }:
    let
      meta = import ./meta { };
      mkNixosHost = name: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            meta = meta;
            system = system;
          };
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            agenix.nixosModules.default
          ];
        };
      mkDarwinHost = name: system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            meta = meta;
            system = system;
          };
          modules = [
            ./hosts/${name}
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            agenix.darwinModules.default
          ];

        };
    in {

      ## Nixos Hosts
      nixosConfigurations.onix = mkNixosHost "onix" "x86_64-linux";
      nixosConfigurations.altaria = mkNixosHost "altaria" "x86_64-linux";

      ## Darwin Hosts
      darwinConfigurations.applin = mkDarwinHost "applin" "aarch64-darwin";
    };
}
