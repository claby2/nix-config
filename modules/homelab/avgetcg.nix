{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.avgetcg;
in
{
  options.homelab.avgetcg = {
    enable = lib.mkEnableOption "avgetcg";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
    user = lib.mkOption {
      type = lib.types.str;
      description = "User to run the avgetcg services as.";
    };
    directory = lib.mkOption {
      type = lib.types.path;
      description = "Working directory for the avgetcg card game repository.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable SSL for the nginx virtual host.

    systemd = {
      services.avgetcg = {
        description = "avgetcg card game server";
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

      services.avgetcg-git-pull = {
        description = "git pull for avgetcg repository";
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

      timers.avgetcg-git-pull = {
        description = "Run git pull for avgetcg every 30 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:00,30";
        };
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
