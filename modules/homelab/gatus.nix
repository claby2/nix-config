{ config, lib, ... }:
let cfg = config.homelab.gatus;
in {
  options.homelab.gatus = {
    enable = lib.mkEnableOption "gatus";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web.port = cfg.port;
        url = cfg.host;
        endpoints = [{
          name = "personal";
          url = "https://edwardwibowo.com";
          interval = "5m";
          conditions = [ "[STATUS] == 200" ];
        }];
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:${toString cfg.port}/"; };
    };
  };
}
