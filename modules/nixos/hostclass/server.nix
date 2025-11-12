{ pkgs, lib, config, ... }:
let cfg = config.hostclass.server;
in {
  options.hostclass.server = {
    enable = lib.mkEnableOption "server hostclass";
    motd = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;
    users.motd = cfg.motd;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkAfter "server";
    environment.systemPackages = with pkgs; [ strace lsof tcpdump ];

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
  };

}
