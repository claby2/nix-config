{ pkgs, config, modulesPath, meta, inputs, ... }: {
  imports = [ ./hardware.nix (modulesPath + "/profiles/qemu-guest.nix") ];
  hostclass.server = {
    enable = true;
    motd = builtins.readFile "${inputs.self}/hosts/onix/onix";
  };

  system.stateVersion = "23.11";

  # === AGE
  age.secrets.restic-repository.file = ./secrets/restic-repository.age;
  age.secrets.restic-password.file = ./secrets/restic-password.age;
  age.secrets.restic-environment.file = ./secrets/restic-environment.age;
  age.secrets.freshrss = {
    file = ./secrets/freshrss.age;
    owner = "freshrss";
    group = "freshrss";
  };
  age.secrets.grafana-password = {
    file = ./secrets/grafana-password.age;
    owner = "grafana";
    group = "grafana";
  };

  # === SERVICES
  services.tailscale.enable = true;
  services.restic.backups.onix = {
    initialize = true;
    paths = [ "/var/lib" "/etc/ssh" ];
    pruneOpts =
      [ "--keep-within 7d" "--keep-monthly 12" "--keep-yearly 5" "--prune" ];
    extraBackupArgs = [ "--cache-dir" "/var/cache/restic-cache" ];
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
    };
    repositoryFile = config.age.secrets.restic-repository.path;
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-environment.path;
  };

  # === HOMELAB
  homelab.metrics = {
    enable = true;
    grafanaAdminPassword =
      "$__file{${config.age.secrets.grafana-password.path}}";
    ports = {
      grafana = 3003;
      prometheus = 3004;
      nodeExporter = 3005;
    };
  };
  homelab.filebrowser = {
    enable = true;
    port = 3001;
    host = "filebrowser.edwardwibowo.com";
  };
  homelab.personal = {
    enable = true;
    host = "edwardwibowo.com";
  };
  homelab.amy = {
    enable = true;
    host = "amyqiao.com";
  };
  homelab.freshrss = {
    enable = true;
    host = "freshrss.edwardwibowo.com";
    passwordFile = config.age.secrets.freshrss.path;
  };
  homelab.gitea = {
    enable = true;
    port = 3000;
    host = "git.edwardwibowo.com";
  };

  # === USERS
  users.users = {
    root = { openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ]; };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
    };
  };

  # === HOME
  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };
}
