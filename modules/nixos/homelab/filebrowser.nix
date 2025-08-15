{ config, lib, ... }:
let cfg = config.homelab.filebrowser;
in {
  options.homelab.filebrowser = {
    enable = lib.mkEnableOption "filebrowser";
    port = lib.mkOption { type = lib.types.port; };
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      settings.port = cfg.port;
    };

    system.activationScripts.createFilebrowserDir = {
      text = ''
        mkdir -p /var/lib/filebrowser/data
      '';
    };

    # Seems like the freshrss service in nixpkgs does not enable SSL...
    # Forcing that here!
    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:${toString cfg.port}/"; };
    };
  };
}

