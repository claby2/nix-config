{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  environment.systemPackages = with pkgs; [ strace lsof ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry.tty;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.variables.HOSTCLASS = lib.mkAfter "server";
}
