{
  meta,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.homelab.dns;
  tld = meta.internalTld;
  fqdn = sub: "${sub}.${tld}";
in
{
  options.homelab.dns = {
    server.enable = lib.mkEnableOption "authoritative dnsmasq server for the .${tld} zone";
    entries = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
      example = {
        grafana = 3001;
      };
      description = ''
        Services on this host reachable via the internal TLD, mapping bare
        subdomain (e.g. "grafana") to the local port nginx proxies to.
        The full domain is "<subdomain>.''${meta.internalTld}"; the dns
        server aggregates entries from every host to build the zone.
      '';
    };
    fqdns = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default = lib.mapAttrs (sub: _: fqdn sub) cfg.entries;
      description = ''
        Full internal domain for each entry (subdomain -> fqdn), for
        services that need to know their own URL (e.g. grafana root_url).
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.entries != { }) {
      services.nginx.virtualHosts = lib.mapAttrs' (
        sub: port:
        lib.nameValuePair (fqdn sub) {
          # Default listen (port 80). Plain HTTP; traffic rides Tailscale.
          #
          # Restrict to tailnet source addresses: these vhosts share the
          # global 0.0.0.0:80 listener and are selected purely by Host
          # header, so on hosts that also open port 80 publicly (for
          # ACME/public vhosts) anyone could reach them by sending
          # "Host: <sub>.${tld}" to the public IP — no public DNS record
          # needed. The interface-scoped firewall rule below doesn't
          # protect against that, and binding to the tailscale IP instead
          # would race tailscale0 coming up at boot; a source ACL has
          # neither problem. Tailnet traffic always arrives from
          # 100.64.0.0/10 (or Tailscale's IPv6 ULA range), including a
          # host talking to its own services.
          extraConfig = ''
            allow 100.64.0.0/10;
            allow fd7a:115c:a1e0::/48;
            allow 127.0.0.1;
            deny all;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString port}/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host ${fqdn sub};
            '';
          };
        }
      ) cfg.entries;

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 ];
    })

    (lib.mkIf cfg.server.enable (
      let
        # The zone is derived from every host's homelab.dns.entries; each
        # record points at the owning host's tailnet IP.
        entriesByHost = lib.filterAttrs (_: entries: entries != { }) (
          lib.mapAttrs (_: hostCfg: hostCfg.config.homelab.dns.entries or { }) inputs.self.nixosConfigurations
        );
        zone = lib.concatMapAttrs (
          host: entries:
          lib.mapAttrs' (sub: _: lib.nameValuePair (fqdn sub) meta.tailscaleIPs.${host}) entries
        ) entriesByHost;
        hostsMissingIP = lib.attrNames (
          lib.filterAttrs (host: _: !(meta.tailscaleIPs ? ${host})) entriesByHost
        );
        totalEntries = lib.foldlAttrs (
          n: _: entries:
          n + lib.length (lib.attrNames entries)
        ) 0 entriesByHost;
      in
      {
        assertions = [
          {
            assertion = hostsMissingIP == [ ];
            message = "homelab.dns: host(s) ${toString hostsMissingIP} define dns entries but have no meta.tailscaleIPs entry";
          }
          {
            assertion = lib.length (lib.attrNames zone) == totalEntries;
            message = "homelab.dns: the same subdomain is defined in homelab.dns.entries on more than one host";
          }
        ];

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
            # No upstreams; queries outside the internal TLD are REFUSED —
            # fine, since Tailscale split DNS only routes that TLD here.
            no-resolv = true;
            no-hosts = true;
            # Authoritative for the internal TLD: unknown names => NXDOMAIN.
            local = "/${tld}/";
            address = lib.mapAttrsToList (domain: ip: "/${domain}/${ip}") zone;
          };
        };

        networking.firewall.interfaces."tailscale0" = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      }
    ))
  ];
}
