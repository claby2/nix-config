{ pkgs, lib, config, ... }:
let cfg = config.hostclass.server;
in {
  options.hostclass.server = {
    enable = lib.mkEnableOption "server hostclass";
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkAfter "server";
    environment.systemPackages = with pkgs; [ strace lsof ];

    # === PROGRAMS
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry.tty;
    };

    # === SERVICES
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.AllowAgentForwarding = true;
    };
  };

}
