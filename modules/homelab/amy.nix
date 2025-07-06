{ lib, config, pkgs, ... }:
let cfg = config.homelab.amy;
in {
  options.homelab.amy = {
    enable = lib.mkEnableOption "amy's website";
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."amy-clone" = {
      description = "clone amy's website";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      script = ''
        set -eu
        ${pkgs.git}/bin/git init -q
        ${pkgs.git}/bin/git remote add origin https://github.com/amyqcs/amyqiao || true
        ${pkgs.git}/bin/git fetch --depth 1 origin main
        ${pkgs.git}/bin/git checkout -B main FETCH_HEAD
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "claby2";
        StateDirectory = "amy";
        WorkingDirectory = "/var/lib/amy";
      };
    };

    systemd.timers."amy-clone" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "amy-clone.service";
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { root = "/var/lib/amy"; };
    };
  };

}

