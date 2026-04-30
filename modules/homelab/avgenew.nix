{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.avgenew;
in
{
  options.homelab.avgenew = {
    enable = lib.mkEnableOption "avge new";
    frontendPort = lib.mkOption { type = lib.types.port; };
    backendPort = lib.mkOption { type = lib.types.port; };
    frontendHost = lib.mkOption { type = lib.types.str; };
    backendHost = lib.mkOption { type = lib.types.str; };
    user = lib.mkOption {
      type = lib.types.str;
      description = "User to run the avge services as.";
    };
    frontendDirectory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avge card game repository.";
    };
    backendDirectory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avge card game repository.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable SSL for the nginx virtual host.

    systemd = {
      services.avgenewfrontend = {
        description = "avge card game server";
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

      services.avgenewfrontend-git-pull = {
        description = "git pull for avge repository";
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

      timers.avgenewfrontend-git-pull = {
        description = "Run git pull for avge every 30 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:00,30";
        };
      };

      # BACKEND

      services.avgenewbackend =
        let
          pythonEnv = pkgs.python3.withPackages (
            ps: with ps; [
              flask
              flask-socketio
              pytest
            ]
          );
        in
        {
          description = "avge card game server";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            WorkingDirectory = cfg.backendDirectory;
            Environment = [
              "ROUTER_PORT=${toString cfg.backendPort}"
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

      services.avgenewbackend-git-pull = {
        description = "git pull for avge repository";
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

      timers.avgenewbackend-git-pull = {
        description = "Run git pull for avge every 30 minutes";
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
