{ inputs, config, lib, pkgs, ... }:
let cfg = config.homelab.personal;
in {

  options.homelab.personal = {
    enable = lib.mkEnableOption "personal website";
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."personal-clone" = {
      description = "clone personal website";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      script = ''
        set -eu
        ${pkgs.git}/bin/git init -q
        ${pkgs.git}/bin/git remote add origin https://github.com/claby2/claby2.github.io || true
        ${pkgs.git}/bin/git fetch --depth 1 origin gh-pages
        ${pkgs.git}/bin/git checkout -B gh-pages FETCH_HEAD
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "claby2";
        StateDirectory = "personal";
        WorkingDirectory = "/var/lib/personal";
      };
    };

    systemd.timers."personal-clone" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "personal-clone.service";
      };
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { root = "/var/lib/personal"; };
    };
  };
}
