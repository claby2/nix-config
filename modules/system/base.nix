# Essential stuff that every *system* should have configured!
{ inputs, pkgs, lib, ... }: {
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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry.tty;
  };

  environment.variables.HOSTCLASS = lib.mkDefault "base";
}
