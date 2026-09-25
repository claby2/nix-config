{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.gitea;
  hosting = config.homelab.hosting.gitea;
in
{

  options.homelab.gitea = {
    enable = lib.mkEnableOption "gitea";
    port = lib.mkOption { type = lib.types.port; };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;

      settings = {
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = cfg.port;
          ROOT_URL = "${hosting.url}/";
        };
        # TODO: Things break if I remove mailer config... >.<
        mailer = {
          ENABLED = false;
          SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
        };
      };
    };

    homelab.hosting.gitea.vhost = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
        extraConfig = ''
          client_max_body_size 512M;
          proxy_set_header Connection $http_connection;
          proxy_set_header Upgrade $http_upgrade;
        '';
      };
    };
  };
}
