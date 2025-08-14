# Essential stuff that every *system* should have configured!
{ inputs, pkgs, lib, ... }: {
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
}
