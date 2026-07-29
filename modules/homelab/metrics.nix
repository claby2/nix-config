{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.metrics;
in
{

  options.homelab.metrics.grafana = {
    enable = lib.mkEnableOption "grafana";
    adminPassword = lib.mkOption { type = lib.types.str; };
    secretKey = lib.mkOption { type = lib.types.str; };
    port = lib.mkOption { type = lib.types.port; };
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Domain grafana is served from (sets server.domain/root_url).";
    };
  };

  options.homelab.metrics.prometheus = {
    enable = lib.mkEnableOption "prometheus";
    port = lib.mkOption { type = lib.types.port; };
    nodeExporterPort = lib.mkOption { type = lib.types.port; };
  };

  config = {
    services = {
      grafana = lib.mkIf cfg.grafana.enable {
        enable = true;
        settings = {
          server = {
            http_port = cfg.grafana.port;
          }
          // lib.optionalAttrs (cfg.grafana.domain != null) {
            domain = cfg.grafana.domain;
            root_url = "http://${cfg.grafana.domain}/";
          };
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
    };
  };
}
