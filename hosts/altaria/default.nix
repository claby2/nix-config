{
  config,
  ...
}:
{
  imports = [
    (import ../../hostclass/server.nix { motd = builtins.readFile ./altaria; })
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  nix.settings.extra-trusted-users = [ "claby2" ];

  # === AGE
  age.secrets = {
    restic-repository.file = ./secrets/restic-repository.age;
    restic-password.file = ./secrets/restic-password.age;
    restic-environment.file = ./secrets/restic-environment.age;
    freshrss = {
      file = ./secrets/freshrss.age;
      owner = "freshrss";
      group = "freshrss";
    };
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

  # === SERVICES
  services.restic.backups.altaria = {
    initialize = true;
    paths = [
      "/var/lib"
      "/etc/ssh"
    ];
    pruneOpts = [
      "--keep-within 7d"
      "--keep-monthly 12"
      "--keep-yearly 5"
      "--prune"
    ];
    extraBackupArgs = [
      "--cache-dir"
      "/var/cache/restic-cache"
    ];
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
    };
    repositoryFile = config.age.secrets.restic-repository.path;
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-environment.path;
  };

  # === HOMELAB
  homelab = {
    metrics = {
      enable = true;
      hostname = "altaria";
      grafanaAdminPassword = "$__file{${config.age.secrets.grafana-password.path}}";
      grafanaSecretKey = "$__file{${config.age.secrets.grafana-secret-key.path}}";
      ports = {
        grafana = 3003;
        prometheus = 3004;
        nodeExporter = 3005;
      };
    };
    filebrowser = {
      enable = true;
      port = 3001;
      host = "filebrowser.edwardwibowo.com";
    };
    personal = {
      enable = true;
      host = "edwardwibowo.com";
    };
    amy = {
      enable = true;
      host = "amyqiao.com";
    };
    freshrss = {
      enable = true;
      host = "freshrss.edwardwibowo.com";
      passwordFile = config.age.secrets.freshrss.path;
    };
    gitea = {
      enable = true;
      port = 3000;
      host = "git.edwardwibowo.com";
    };
  };
}
