{ config, ... }: {
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "26.11";
  users.motd = builtins.readFile ./cherrim;

  # === AGE
  age.secrets = {
    grafana-password = {
      file = ./secrets/grafana-password.age;
      owner = "grafana";
      group = "grafana";
    };
    grafana-secret-key = {
      file = ./secrets/grafana-secret-key.age;
      owner = "grafana";
      group = "grafana";
    };
  };

  # === HOMELAB
  homelab = {
    dns = {
      server.enable = true;
      entries = {
        "grafana" = config.homelab.metrics.grafana.port;
        "cherrim.prometheus" = config.homelab.metrics.prometheus.port;
        "silph" = config.homelab.silph.server.port;
        "cherrim.silph-collector" = config.homelab.silph.collector.port;
      };
    };
    silph = {
      collector = {
        enable = true;
        port = 9100;
      };
      server = {
        enable = true;
        port = 8080;
        targets = {
          cherrim = "http://cherrim.silph-collector.internal";
          onix = "http://onix.silph-collector.internal";
          altaria = "http://altaria.silph-collector.internal";
        };
      };
    };
    metrics = {
      grafana = {
        enable = true;
        adminPassword = "$__file{${config.age.secrets.grafana-password.path}}";
        secretKey = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        port = 3001;
        domain = config.homelab.dns.fqdns.grafana;
      };
      prometheus = {
        enable = true;
        port = 3002;
        nodeExporterPort = 3003;
      };
    };
  };
}
