{
  meta,
  config,
  lib,
  inputs,
  ...
}:
# Authoritative dnsmasq server for the internal TLD, serving the tailnet.
# The zone is derived from every host's `homelab.hosting.<name>.internal`
# (see hosting.nix); each record points at the owning host's tailnet IP.
# Tailscale split DNS in the admin console routes the TLD to this host.
let
  cfg = config.homelab.dns;
  tld = meta.internalTld;

  # [ { host; name; } ] for every internal name across all hosts.
  records = lib.sort (a: b: a.name < b.name) (
    lib.concatLists (
      lib.mapAttrsToList (
        host: hostCfg:
        map (s: {
          inherit host;
          name = "${s.internal}.${tld}";
        }) (lib.filter (s: s.internal != null) (lib.attrValues hostCfg.config.homelab.hosting))
      ) inputs.self.nixosConfigurations
    )
  );
  names = map (r: r.name) records;
  duplicates = lib.unique (lib.filter (n: lib.count (m: m == n) names > 1) names);
  hostsMissingIP = lib.unique (
    map (r: r.host) (lib.filter (r: !(meta.tailscaleIPs ? ${r.host})) records)
  );
in
{
  options.homelab.dns.server.enable =
    lib.mkEnableOption "authoritative dnsmasq server for the .${tld} zone";

  config = lib.mkIf cfg.server.enable {
    assertions = [
      {
        assertion = hostsMissingIP == [ ];
        message = "homelab.dns: host(s) ${toString hostsMissingIP} define internal names but have no meta.tailscaleIPs entry";
      }
      {
        assertion = duplicates == [ ];
        message = "homelab.dns: internal name(s) ${toString duplicates} are defined on more than one host";
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
        address = map (r: "/${r.name}/${meta.tailscaleIPs.${r.host}}") records;
      };
    };

    networking.firewall.interfaces."tailscale0" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}
