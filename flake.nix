{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      meta = import ./meta { };
      mkHost = name: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            meta = meta;
          };
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
    in {

      nixosConfigurations.onix = mkHost "onix" "x86_64-linux";
      # TODO: add altaria
      # nixosConfigurations.onix = mkHost "altaria" "x86_64-linux";
    };

}
