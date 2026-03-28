{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.gitea;
in
{

  options.homelab.gitea = {
    enable = lib.mkEnableOption "gitea";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;

      settings = {
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          HTTP_PORT = cfg.port;
          ROOT_URL = "https://${cfg.host}/";
        };
        # TODO: Things break if I remove mailer config... >.<
        mailer = {
          ENABLED = false;
          SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
        };
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        extraConfig = ''
          client_max_body_size 512M;
          proxy_set_header Connection $http_connection;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
