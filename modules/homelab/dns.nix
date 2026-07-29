{
  meta,
  config,
  lib,
  ...
}:
let
  hostname = config.networking.hostName;
  cfg = config.homelab.dns;
in
{
  options.homelab.dns = {
    server.enable = lib.mkEnableOption "authoritative dnsmasq server for the .internal zone";
    entries = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
      description = ''
        Internal domains served from this host, mapping domain
        (e.g. "grafana.internal") to the local port nginx proxies to.
        Each domain must also be registered in meta.internalDomains.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.entries != { }) {
      assertions = [
        {
          assertion = lib.all (
            domain: (meta.internalDomains.${domain} or null) == hostname
          ) (lib.attrNames cfg.entries);
          message = "homelab.dns.entries on ${hostname} contains a domain not mapped to ${hostname} in meta.internalDomains";
        }
      ];

      services.nginx.virtualHosts = lib.mapAttrs (domain: port: {
        # Default listen (port 80). Plain HTTP; traffic rides Tailscale.
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host ${domain};
          '';
        };
      }) cfg.entries;

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 ];
    })

    (lib.mkIf cfg.server.enable {
      services.dnsmasq = {
        enable = true;
        # Don't make dnsmasq this host's own resolver — it has no upstreams
        # and would break the host's general name resolution.
        resolveLocalQueries = false;
        settings = {
          interface = "tailscale0";
          # tailscale0 may appear after dnsmasq starts; bind dynamically
          # instead of failing at boot (vs bind-interfaces).
          bind-dynamic = true;
          # No upstreams; non-.internal queries are REFUSED — fine, since
          # Tailscale split DNS only routes "internal" queries here.
          no-resolv = true;
          no-hosts = true;
          # Authoritative for .internal: unknown names => NXDOMAIN.
          local = "/internal/";
          address = lib.mapAttrsToList (
            domain: host: "/${domain}/${meta.tailscaleIPs.${host}}"
          ) meta.internalDomains;
        };
      };

      networking.firewall.interfaces."tailscale0" = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };
    })
  ];
}
