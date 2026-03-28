{
  motd ? "",
}:
{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  hostclass.name = "server";

  # === ASSERTIONS
  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "The 'server' hostclass can only be used on NixOS (Linux) systems.";
    }
  ];

  # === MOTD
  users.motd = motd;

  # === ENVIRONMENT
  environment.systemPackages = with pkgs; [
    strace
    lsof
    tcpdump
  ];

  # === PROGRAMS
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
  programs.zsh.syntaxHighlighting.enable = true;

  # === SERVICES
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.AllowAgentForwarding = true;
  };
}
