{ config, lib, ... }:
let
  cfg = config.homelab.freshrss;
  hosting = config.homelab.hosting.freshrss;
in
{
  options.homelab.freshrss = {
    enable = lib.mkEnableOption "freshrss";
    passwordFile = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      baseUrl = hosting.url;
      inherit (cfg) passwordFile;
      virtualHost = hosting.fqdn;
    };

    # The nixpkgs freshrss module builds the vhost itself (php-fpm
    # locations, root); register an empty fragment so the hosting layer
    # adds listen/TLS onto that same vhost.
    homelab.hosting.freshrss.vhost = { };
  };
}
