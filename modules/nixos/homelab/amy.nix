{ inputs, lib, config, ... }:
let cfg = config.homelab.amy;
in {
  options.homelab.amy = {
    enable = lib.mkEnableOption "amy's website";
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { root = "${inputs.amy}"; };
    };
  };

}

