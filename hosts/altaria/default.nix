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
    samba-password.file = ./secrets/samba-password.age;
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
    edge = true;
    hosting = {
      personal.public = "edwardwibowo.com";
      freshrss.public = "freshrss.edwardwibowo.com";
      gitea.public = "git.edwardwibowo.com";
      silph-collector.internal = "altaria.silph-collector";
    };
    silph.collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
      };
    };
    files = {
      enable = true;
      passwordFile = config.age.secrets.samba-password.path;
    };
    personal.enable = true;
    freshrss = {
      enable = true;
      passwordFile = config.age.secrets.freshrss.path;
    };
    gitea = {
      enable = true;
      port = 3000;
    };
  };
}
