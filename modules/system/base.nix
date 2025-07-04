# Essential stuff that every *system* should have configured!
{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    tree

  ];
  environment.variables.EDITOR = "vim";

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry.tty;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };

  environment.variables.HOSTCLASS = lib.mkDefault "base";
}
