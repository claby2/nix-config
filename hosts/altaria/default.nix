{
  config,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  users.motd = builtins.readFile ./altaria;

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
    metrics.prometheus = {
      enable = true;
      port = 3004;
      nodeExporterPort = 3005;
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
