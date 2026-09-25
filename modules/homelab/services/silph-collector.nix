{ config, lib, ... }:
let
  cfg = config.homelab.silph-collector;
in
{
  options.homelab.silph-collector = {
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

  config = lib.mkIf cfg.enable {
    services.silph.collector = {
      enable = true;
      settings = {
        listen = "127.0.0.1:${toString cfg.port}";
        inherit (cfg) metrics;
      };
    };
    homelab.hosting.silph-collector.vhost.locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      proxyWebsockets = true;
    };
  };
}
