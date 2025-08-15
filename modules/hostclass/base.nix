# Essential stuff that every *system* should have configured!
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

    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      htop
      tree
      inputs.agenix.packages."${system}".default
      inputs.hladmin.packages."${system}".default
    ];
    environment.variables.EDITOR = "vim";

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
    };

    nixpkgs.config.allowUnfree = true;

    environment.variables.HOSTCLASS = lib.mkDefault "base";
  };
}
