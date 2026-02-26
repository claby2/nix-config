{ config, lib, ... }:
let
  cfg = config.homelab.avge;
in
{
  options.homelab.avge = {
    enable = lib.mkEnableOption "avge";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    # Seems like the freshrss service in nixpkgs does not enable SSL...
    # Forcing that here!
    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
