{
  meta,
  config,
  lib,
  ...
}:
let
  hostname = config.networking.hostName;
  cfg = config.homelab.metrics;
in
{

  options.homelab.metrics.grafana = {
    enable = lib.mkEnableOption "grafana";
    adminPassword = lib.mkOption { type = lib.types.str; };
    secretKey = lib.mkOption { type = lib.types.str; };
    port = lib.mkOption { type = lib.types.port; };
  };

  options.homelab.metrics.prometheus = {
    enable = lib.mkEnableOption "prometheus";
    port = lib.mkOption { type = lib.types.port; };
    nodeExporterPort = lib.mkOption { type = lib.types.port; };
  };

  config =
    let
      host = "${hostname}.${meta.tailnetName}";
    in
    {
      services = {
        grafana = lib.mkIf cfg.grafana.enable {
          enable = true;
          settings = {
            server.http_port = cfg.grafana.port;
            security.admin_password = cfg.grafana.adminPassword;
            security.secret_key = cfg.grafana.secretKey;
          };
        };

        prometheus = lib.mkIf cfg.prometheus.enable {
          enable = true;
          inherit (cfg.prometheus) port;
          exporters = {
            node = {
              enable = true;
              enabledCollectors = [ "systemd" ];
              port = cfg.prometheus.nodeExporterPort;
            };
          };
          scrapeConfigs = [
            {
              job_name = "node";
              static_configs = [ { targets = [ "127.0.0.1:${toString cfg.prometheus.nodeExporterPort}" ]; } ];
            }
          ];
        };

        nginx.virtualHosts."${host}" = lib.mkIf cfg.grafana.enable {
          listen = [
            {
              addr = host;
              inherit (cfg.grafana) port;
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.grafana.port}/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host ${host};
            '';
          };
        };
      };
    };
}
