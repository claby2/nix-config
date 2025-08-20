{ config, lib, ... }:
let cfg = config.homelab.metrics;
in {

  options.homelab.metrics = {
    enable = lib.mkEnableOption "metrics (grafana + prometheus)";
    grafanaAdminPassword = lib.mkOption { type = lib.types.str; };
    ports = lib.mkOption {
      type = lib.types.submodule {
        options = {
          grafana = lib.mkOption { type = lib.types.port; };
          prometheus = lib.mkOption { type = lib.types.port; };
          nodeExporter = lib.mkOption { type = lib.types.port; };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server.http_port = cfg.ports.grafana;
        security.admin_password = cfg.grafanaAdminPassword;
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.ports.prometheus;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = cfg.ports.nodeExporter;
        };
      };
      scrapeConfigs = [{
        job_name = "node";
        static_configs =
          [{ targets = [ "127.0.0.1:${toString cfg.ports.nodeExporter}" ]; }];
      }];
    };

  };
}
