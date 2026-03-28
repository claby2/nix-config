{ config, lib, ... }:
let
  cfg = config.homelab.gatus;
in
{
  options.homelab.gatus = {
    enable = lib.mkEnableOption "gatus";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
    endpoints = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            url = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = [ ];
      description = "Simple endpoints that check for HTTP 200 with Discord alerting.";
    };
    manualEndpoints = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Fully custom endpoint configurations.";
    };
    extraAlerting = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional alerting configurations beyond the default Discord alerting.";
    };
    environmentFile = lib.mkOption { type = lib.types.nullOr lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      inherit (cfg) environmentFile;
      settings = {
        web.port = cfg.port;
        url = cfg.host;
        endpoints =
          (map (ep: {
            inherit (ep) name url;
            interval = "5m";
            conditions = [ "[STATUS] == 200" ];
            alerts = [ { type = "discord"; } ];
          }) cfg.endpoints)
          ++ cfg.manualEndpoints;
        alerting = {
          discord = {
            webhook-url = "$DISCORD_WEBHOOK_URL";
            default-alert = {
              send-on-resolved = true;
              failure-threshold = 1;
            };
          };
        }
        // cfg.extraAlerting;
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      };
    };
  };
}
