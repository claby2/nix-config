{ pkgs, lib, config, ... }:
let cfg = config.hostclass.server;
in {
  imports = [ ./base.nix ];

  options.hostclass.server = {
    enable = lib.mkEnableOption "server hostclass";
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    environment.systemPackages = with pkgs; [ strace lsof ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.AllowAgentForwarding = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry.tty;
    };

    environment.variables.HOSTCLASS = lib.mkAfter "server";
  };

}
