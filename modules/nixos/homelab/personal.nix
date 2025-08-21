{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.homelab.personal;
  webPkg = inputs.personal-website.packages."${pkgs.system}".default;
in {

  options.homelab.personal = {
    enable = lib.mkEnableOption "personal website";
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ webPkg ];

    system.activationScripts.deployWebsite = {
      text = ''
        mkdir -p /var/lib/personal
        cp -r ${webPkg}/. /var/lib/personal/
      '';
    };

    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = { root = "/var/lib/personal"; };
    };
  };
}
