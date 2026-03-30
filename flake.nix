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
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      agenix,
      ...
    }@inputs:
    let
      meta = import ./meta { };

      mkHost =
        builder: system: hostclass: hostname:
        builder {
          inherit system;
          specialArgs = { inherit inputs meta; };
          modules = [
            ./hostclass/${hostclass}.nix
            ./hosts/${hostname}
          ];
        };
      mkNixosHost = mkHost nixpkgs.lib.nixosSystem;
      mkDarwinHost = mkHost nix-darwin.lib.darwinSystem;
    in
    {

      ## Nixos Hosts
      nixosConfigurations = {
        onix = mkNixosHost "x86_64-linux" "server" "onix";
        altaria = mkNixosHost "x86_64-linux" "server" "altaria";
        groudon = mkNixosHost "x86_64-linux" "nixos" "groudon";
      };

      ## Darwin Hosts
      darwinConfigurations.applin = mkDarwinHost "aarch64-darwin" "mac" "applin";
    };
}
