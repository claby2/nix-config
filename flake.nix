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

    amy = {
      url = "git+ssh://git@github.com/amyqcs/amyqiao?ref=main";
      flake = false;
    };

    hladmin = {
      url = "github:claby2/hladmin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code.url = "github:sadjow/claude-code-nix";

    codex-cli.url = "github:sadjow/codex-cli-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      agenix,
      ...
    }:
    let
      meta = import ./meta { };
      mkNixosHost =
        name: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs meta; };
          modules = [
            ./hosts/${name}
            ./modules/hostclass.nix
            ./modules/home
            ./modules/homelab
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            agenix.nixosModules.default
          ];
        };
      mkDarwinHost =
        name: system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs meta; };
          modules = [
            ./hosts/${name}
            ./modules/hostclass.nix
            ./modules/home
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            agenix.darwinModules.default
          ];

        };
    in
    {

      ## Nixos Hosts
      nixosConfigurations = {
        onix = mkNixosHost "onix" "x86_64-linux";
        altaria = mkNixosHost "altaria" "x86_64-linux";
        groudon = mkNixosHost "groudon" "x86_64-linux";
      };

      ## Darwin Hosts
      darwinConfigurations.applin = mkDarwinHost "applin" "aarch64-darwin";
    };
}
