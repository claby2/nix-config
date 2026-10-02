{ config, lib, ... }:
let
  cfg = config.homelab.silph-server;
  targetType = lib.types.submodule {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        description = "Collector base URL to scrape.";
      };
      icon = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
        default = null;
        description = "Dashboard icon: an http(s) URL or a local image file.";
      };
    };
  };
in
{
  options.homelab.silph-server = {
    enable = lib.mkEnableOption "silph server";
    port = lib.mkOption { type = lib.types.port; };
    targets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.coercedTo lib.types.str (url: { inherit url; }) targetType);
      default = { };
      description = "Collectors to scrape, keyed by display name.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.silph.server = {
      enable = true;
      settings = {
        listen = "127.0.0.1:${toString cfg.port}";
        targets = lib.mapAttrsToList (
          name: target:
          {
            inherit name;
            inherit (target) url;
          }
          // lib.optionalAttrs (target.icon != null) { icon = toString target.icon; }
        ) cfg.targets;
      };
    };
    homelab.hosting.silph-server.vhost.locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      proxyWebsockets = true;
    };
  };
}
