{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  environment.systemPackages = with pkgs; [ strace lsof ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.AllowAgentForwarding = true;
  };

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry.tty;

  environment.variables.HOSTCLASS = lib.mkAfter "server";
}
