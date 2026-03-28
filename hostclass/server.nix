{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./base.nix ];

  environment.variables.HOSTCLASS = lib.mkAfter "server";

  # === MOTD
  users.motd = "TODO";

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

  # === SERVICES
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.AllowAgentForwarding = true;
  };

}
