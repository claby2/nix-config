{
  config,
  ...
}:
let
  endpoint = name: url: { inherit name url; };
in
{
  imports = [
    (import ../../hostclass/server.nix { motd = builtins.readFile ./onix; })
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  nix.settings.extra-trusted-users = [ "claby2" ];

  # === AGE
  age.secrets = {
    gatus-environment.file = ./secrets/gatus-environment.age;
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
    avge = {
      enable = true;
      port = 6767;
      host = "tcg.brownavge.org";
      user = "claby2";
      directory = "/home/claby2/avge-card-game";
    };
    metrics = {
      enable = true;
      hostname = "onix";
      grafanaAdminPassword = "$__file{${config.age.secrets.grafana-password.path}}";
      grafanaSecretKey = "$__file{${config.age.secrets.grafana-secret-key.path}}";
      ports = {
        grafana = 3001;
        prometheus = 3002;
        nodeExporter = 3003;
      };
    };
    gatus = {
      enable = true;
      port = 3000;
      host = "gatus.edwardwibowo.com";
      endpoints = [
        (endpoint "personal" "https://edwardwibowo.com")
        (endpoint "filebrowser" "https://filebrowser.edwardwibowo.com")
        (endpoint "freshrss" "https://freshrss.edwardwibowo.com")
        (endpoint "git" "https://git.edwardwibowo.com")
        (endpoint "amy" "https://amyqiao.com")
      ];
      manualEndpoints = [
        {
          name = "altaria ssh";
          url = "ssh://altaria.edwardwibowo.com:22";
          ssh = {
            username = "";
            password = "";
          };
          interval = "5m";
          conditions = [
            "[CONNECTED] == true"
            "[STATUS] == 0"
          ];
          alerts = [ { type = "discord"; } ];
        }
      ];
      environmentFile = config.age.secrets.gatus-environment.path;
    };
  };
}
