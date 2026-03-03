{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.avge;
in
{
  options.homelab.avge = {
    enable = lib.mkEnableOption "avge";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
    user = lib.mkOption {
      type = lib.types.str;
      description = "User to run the avge services as.";
    };
    directory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avge card game repository.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable SSL for the nginx virtual host.

    systemd.services.avge = {
      description = "avge card game server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        WorkingDirectory = cfg.directory;
        Environment = [
          "PORT=${toString cfg.port}"
        ];
        ExecStart = "${pkgs.nodejs}/bin/npm run server";
        User = cfg.user;
        Restart = "on-failure";
      };
      path = [
        pkgs.nodejs
        pkgs.bash
        pkgs.coreutils
      ];
    };

    systemd.services.avge-git-pull = {
      description = "git pull for avge repository";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = cfg.directory;
        ExecStart = "${pkgs.git}/bin/git pull";
        User = cfg.user;
      };
      path = [
        pkgs.openssh
        pkgs.bash
        pkgs.coreutils
      ];
    };

    systemd.timers.avge-git-pull = {
      description = "Run git pull for avge every 30 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:00,30";
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
