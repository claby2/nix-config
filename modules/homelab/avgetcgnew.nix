{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.avgetcgnew;
in
{
  options.homelab.avgetcgnew = {
    enable = lib.mkEnableOption "avgetcgnew";
    frontendPort = lib.mkOption { type = lib.types.port; };
    backendPort = lib.mkOption { type = lib.types.port; };
    frontendHost = lib.mkOption { type = lib.types.str; };
    backendHost = lib.mkOption { type = lib.types.str; };
    user = lib.mkOption {
      type = lib.types.str;
      description = "User to run the avgetcgnew services as.";
    };
    frontendDirectory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avgetcgnew card game repository.";
    };
    backendDirectory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avgetcgnew card game repository.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable SSL for the nginx virtual host.

    systemd = {
      services.avgetcgnew-frontend = {
        description = "avgetcgnew card game server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = cfg.frontendDirectory;
          ExecStartPre = "${pkgs.nodejs}/bin/npm install";
          ExecStart = "${pkgs.nodejs}/bin/npm run dev -- --port ${toString cfg.frontendPort}";
          User = cfg.user;
          Restart = "on-failure";
        };
        path = [
          pkgs.nodejs_22
          pkgs.bash
          pkgs.coreutils
        ];
      };

      services.avgetcgnew-frontend-git-pull = {
        description = "git pull for avgetcgnew repository";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = cfg.frontendDirectory;
          ExecStart = "${pkgs.git}/bin/git pull";
          User = cfg.user;
        };
        path = [
          pkgs.openssh
          pkgs.bash
          pkgs.coreutils
        ];
      };

      timers.avgetcgnew-frontend-git-pull = {
        description = "Run git pull for avgetcgnew every 30 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:00,30";
        };
      };

      # BACKEND

      services.avgetcgnew-backend =
        let
          pythonEnv = pkgs.python3.withPackages (
            ps: with ps; [
              flask
              flask-socketio
              pytest
              gevent
            ]
          );
        in
        {
          description = "avgetcgnew card game server";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            WorkingDirectory = cfg.backendDirectory;
            Environment = [
              "ROUTER_PORT=${toString cfg.backendPort}"
              "ROUTER_ALLOWED_ORIGINS=https://${cfg.frontendHost}"
              "ROUTER_COOKIE_SECURE=true"
              "ROUTER_COOKIE_SAMESITE=None"
            ];
            ExecStart = "${pythonEnv}/bin/python3 -m card_game.server.router_server";
            User = cfg.user;
            Restart = "on-failure";
          };
          path = [
            pythonEnv
            pkgs.bash
            pkgs.coreutils
          ];
        };

      services.avgetcgnew-backend-git-pull = {
        description = "git pull for avgetcgnew repository";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = cfg.backendDirectory;
          ExecStart = "${pkgs.git}/bin/git pull";
          User = cfg.user;
        };
        path = [
          pkgs.openssh
          pkgs.bash
          pkgs.coreutils
        ];
      };

      timers.avgetcgnew-backend-git-pull = {
        description = "Run git pull for avgetcgnew every 30 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:00,30";
        };
      };

    };

    services.nginx.virtualHosts.${cfg.frontendHost} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.frontendPort}/";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts.${cfg.backendHost} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.backendPort}/";
        proxyWebsockets = true;
      };
    };
  };
}
