# Essential stuff that every *system* should have configured!
# Ideally, no system should *actually* have base as its hostclass. This
# hostclass mostly serves as a module that other hostclasses inherit from.
{ inputs, pkgs, lib, config, ... }:
let cfg = config.hostclass.base;
in {
  options.hostclass.base = { enable = lib.mkEnableOption "base hostclass"; };

  config = lib.mkIf cfg.enable {
    # Include the git commit hash (and also whether it was dirty at the time of
    # building) in the configuration revision. This shows up when running
    # `nixos-version --configuration-revision` on NixOS or `darwin-version
    # --configuration-revision` on darwin.
    system.configurationRevision =
      inputs.self.rev or inputs.self.dirtyRev or "unknown";

    nixpkgs.config.allowUnfree = true;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkDefault "base";
    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      htop
      tree
      mtr
      inputs.agenix.packages."${system}".default
      inputs.hladmin.packages."${system}".default
    ];
    environment.variables.EDITOR = "vim";

    # === PROGRAMS
    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
