{ config, lib, pkgs, ... }:
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
    # Enable SSL for the nginx virtual host.

    systemd.services.avge = {
      description = "avge card game server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        WorkingDirectory = "/home/claby2/avge-card-game";
        Environment = "PORT=${toString cfg.port}";
        ExecStart = "${pkgs.nodejs}/bin/npm run server";
        User = "claby2";
        Restart = "on-failure";
      };
    };

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
