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

    llm-agents.url = "github:numtide/llm-agents.nix";
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

      overlays = [
        (final: prev: {
          # Overlay to fix j build
          # See:
          # - J Build Issue: https://github.com/NixOS/nixpkgs/issues/479840
          #     - Overlay workaround: https://github.com/NixOS/nixpkgs/issues/479840#issuecomment-3747503791
          # - Parent Issue: https://github.com/NixOS/nixpkgs/issues/475479
          # - Hydra Build Failure: https://hydra.nixos.org/build/324243490
          j = prev.j.overrideAttrs (oldAttrs: {
            NIX_CFLAGS_COMPILE = " -std=gnu17 -Wno-error";
            NIX_CPPFLAGS_COMPILE = " -include stdint.h";
          });
        })
      ];

      mkHost =
        builder: system: hostclass: hostname:
        builder {
          inherit system;
          specialArgs = { inherit inputs meta; };
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.problems.handlers.j.broken = "warn";
            }
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
      darwinConfigurations.applin = mkDarwinHost "aarch64-darwin" "darwin" "applin";
    };
}
