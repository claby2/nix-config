{ config, lib, ... }:
let
  cfg = config.homelab.freshrss;
in
{
  options.homelab.freshrss = {
    enable = lib.mkEnableOption "freshrss";
    host = lib.mkOption { type = lib.types.str; };
    passwordFile = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      baseUrl = "https://${cfg.host}";
      passwordFile = cfg.passwordFile;
      virtualHost = cfg.host;
    };

    # Seems like the freshrss service in nixpkgs does not enable SSL...
    # Forcing that here!
    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
    };
  };
}
