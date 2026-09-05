{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.homelab.silph;
in
{
  imports = [ inputs.silph.nixosModules.default ];

  options.homelab.silph = {
    collector = {
      enable = lib.mkEnableOption "silph collector";
      port = lib.mkOption { type = lib.types.port; };
      metrics = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        example = {
          cpu = { };
          memory = { };
          disk.mounts = [ "/" ];
          temperature = { };
        };
        description = ''
          Metrics to collect, passed through as the collector's `metrics`
          table. Every metric is opt-in: a metric is enabled by the presence
          of its attribute, even an empty one. At least one is required.
        '';
      };
    };
    server = {
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
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.collector.enable {
      services.silph.collector = {
        enable = true;
        settings = {
          listen = "127.0.0.1:${toString cfg.collector.port}";
          metrics = cfg.collector.metrics;
        };
      };
    })
    (lib.mkIf cfg.server.enable {
      services.silph.server = {
        enable = true;
        settings = {
          listen = "127.0.0.1:${toString cfg.server.port}";
          targets = lib.mapAttrsToList (name: url: { inherit name url; }) cfg.server.targets;
        };
      };
    })
  ];
}
