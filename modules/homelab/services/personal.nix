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
  };

  config = lib.mkIf cfg.enable {
    homelab.hosting.personal.vhost = {
      locations."/" = {
        root = "${webPkg}";
      };
    };
  };
}
