{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.personal;
  webPkg = inputs.personal-website.packages."${pkgs.stdenv.hostPlatform.system}".default;
in
{

  options.homelab.personal = {
    enable = lib.mkEnableOption "personal website";
    host = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.host} = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        root = "${webPkg}";
      };
    };
  };
}
