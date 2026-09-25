{ config, lib, ... }:
let
  cfg = config.homelab.silph-server;
in
{
  options.homelab.silph-server = {
    enable = lib.mkEnableOption "silph server";
    port = lib.mkOption { type = lib.types.port; };
    targets = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        onix = "http://onix.silph-collector.internal";
      };
      description = "Collector base URLs to scrape, keyed by display name.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.silph.server = {
      enable = true;
      settings = {
        listen = "127.0.0.1:${toString cfg.port}";
        targets = lib.mapAttrsToList (name: url: { inherit name url; }) cfg.targets;
      };
    };
    homelab.hosting.silph-server.vhost.locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      proxyWebsockets = true;
    };
  };
}
