{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  # Include the git commit hash (and also whether it was dirty at the time of
  # building) in the configuration revision. This shows up when running
  # `nixos-version --configuration-revision` on NixOS or `darwin-version
  # --configuration-revision` on darwin.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or "unknown";

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
    inputs.agenix.packages."${stdenv.hostPlatform.system}".default
    inputs.hladmin.packages."${stdenv.hostPlatform.system}".default
  ];
  environment.variables.EDITOR = "vim";

  # === PROGRAMS
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
}
