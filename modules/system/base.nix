# Essential stuff that every *system* should have configured!
{ inputs, pkgs, lib, ... }:
let dirtyRev = builtins.toString (inputs.self.dirtyRev or "unknown");
in {
  environment.etc."nixos-build-info".text = ''
    ${dirtyRev}
  '';

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    tree
    inputs.agenix.packages."${system}".default
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
