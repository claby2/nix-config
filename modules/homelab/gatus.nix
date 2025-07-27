{ config, lib, ... }:
let cfg = config.homelab.gatus;
in {
  options.homelab.gatus = {
    enable = lib.mkEnableOption "gatus";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
    endpoints = lib.mkOption { };
    alerting = lib.mkOption { };
    environmentFile = lib.mkOption { type = lib.types.nullOr lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        web.port = cfg.port;
        url = cfg.host;
        endpoints = cfg.endpoints;
        alerting = cfg.alerting;
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:${toString cfg.port}/"; };
    };
  };
}
