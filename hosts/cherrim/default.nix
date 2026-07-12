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
    metrics = {
      grafana = {
        enable = true;
        adminPassword = "$__file{${config.age.secrets.grafana-password.path}}";
        secretKey = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        port = 3001;
      };
      prometheus = {
        enable = true;
        port = 3002;
        nodeExporterPort = 3003;
      };
    };
  };
}
