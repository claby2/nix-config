{
  meta,
  config,
  lib,
  inputs,
  ...
}:
# Hosting layer: decides how a service's nginx vhost is exposed. Service
# modules register a vhost fragment (locations, upstream, etc.) under
# `homelab.hosting.<name>.vhost` and know nothing about TLS or the tailnet.
# The host file decides exposure per entry:
#
#   public   = "git.example.com"   reachable from the internet. On an edge
#                                  (VPS) nginx terminates TLS with ACME; on
#                                  a non-edge (home machine) nginx serves
#                                  plain HTTP on the tailnet IP and an edge
#                                  must list it in `homelab.proxy`.
#   internal = "gatus"             reachable from the tailnet only, as
#                                  gatus.<internalTld>, plain HTTP bound to
#                                  the tailnet IP. dns.nix aggregates these
#                                  names into the internal zone.
#
# `homelab.proxy` on an edge maps a public hostname to the non-edge host
# that runs it: nginx terminates TLS and forwards to that host's tailnet IP,
# preserving the Host header so the backend vhost matches by name.
let
  cfg = config.homelab;
  me = config.networking.hostName;
  tld = meta.internalTld;
  peers = lib.filterAttrs (h: _: h != me) inputs.self.nixosConfigurations;
  peerHomelab = h: peers.${h}.config.homelab;
  publicNames =
    homelab: lib.filter (n: n != null) (lib.mapAttrsToList (_: s: s.public) homelab.hosting);

  tailnetVhost = {
    listenAddresses = [ meta.tailscaleIPs.${me} ];
  };
  edgeVhost = {
    addSSL = true;
    enableACME = true;
  };
  mkVhost = s: extra: lib.mkMerge (lib.optional (s.vhost != null) s.vhost ++ [ extra ]);

  publicEntries = lib.filterAttrs (_: s: s.public != null) cfg.hosting;
  internalEntries = lib.filterAttrs (_: s: s.internal != null) cfg.hosting;
  # Entries that bind nginx to the tailnet IP on this host.
  bindsTailnet = internalEntries != { } || (!cfg.edge && publicEntries != { });
in
{
  options.homelab = {
    edge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host terminates public TLS for the public vhosts it hosts.";
    };
    hosting = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }:
          {
            options = {
              public = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Public hostname the service is served at, if any.";
              };
              internal = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Tailnet-only subdomain under the internal TLD, if any.";
              };
              vhost = lib.mkOption {
                type = lib.types.nullOr lib.types.attrs;
                default = null;
                description = ''
                  nginx virtualHost fragment registered by the service module:
                  locations, root, upstream headers. Must not set listen/TLS
                  options; the hosting layer adds those.
                '';
              };
              fqdn = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                default = if config.public != null then config.public else "${config.internal}.${tld}";
                description = "Primary hostname the service is served at (public if set, else internal).";
              };
              url = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                default = if config.public != null then "https://${config.public}" else "http://${config.fqdn}";
                description = "Primary URL of the service, for services that need to know their own address.";
              };
            };
          }
        )
      );
      default = { };
      example = {
        gitea.public = "git.example.com";
        gatus.internal = "gatus";
      };
      description = "Services this host runs, keyed by service name.";
    };
    proxy = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "git.example.com" = "groudon";
      };
      description = "Public hostnames this edge fronts, mapped to the non-edge host that runs them.";
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.proxy == { } || cfg.edge;
          message = "homelab.proxy: ${me} proxies for other hosts but is not an edge (homelab.edge = false)";
        }
      ]
      ++ lib.mapAttrsToList (name: s: {
        assertion = s.vhost != null;
        message = "homelab.hosting.${name} is declared on ${me} but no service module registered a vhost for it (is homelab.${name}.enable set?)";
      }) cfg.hosting
      ++ lib.mapAttrsToList (name: s: {
        assertion = s.public != null || s.internal != null;
        message = "homelab.hosting.${name} on ${me} has neither `public` nor `internal` set";
      }) cfg.hosting
      # Every proxy entry must point at a non-edge peer that hosts that name.
      ++ lib.mapAttrsToList (host: backend: {
        assertion =
          (peers ? ${backend})
          && !(peerHomelab backend).edge
          && lib.elem host (publicNames (peerHomelab backend));
        message = "homelab.proxy: ${me} proxies ${host} to ${backend}, but ${backend} does not host it as a non-edge";
      }) cfg.proxy
      # Every public name hosted on a non-edge must be proxied by some edge,
      # or it is unreachable from outside the tailnet.
      ++ lib.optionals (!cfg.edge) (
        lib.mapAttrsToList (name: s: {
          assertion = lib.any (h: ((peerHomelab h).proxy.${s.public} or null) == me) (lib.attrNames peers);
          message = "homelab.hosting.${name}: ${me} hosts ${s.public} but no edge has homelab.proxy.\"${s.public}\" = \"${me}\"";
        }) publicEntries
      );
    }

    # Public vhosts for services this host runs.
    {
      services.nginx.virtualHosts = lib.mapAttrs' (
        _: s: lib.nameValuePair s.public (mkVhost s (if cfg.edge then edgeVhost else tailnetVhost))
      ) publicEntries;
    }

    # Internal (tailnet-only) vhosts for services this host runs.
    {
      services.nginx.virtualHosts = lib.mapAttrs' (
        _: s: lib.nameValuePair "${s.internal}.${tld}" (mkVhost s tailnetVhost)
      ) internalEntries;
    }

    # Let nginx bind the tailnet IP even if tailscale0 is not up yet at
    # start, and admit tailnet HTTP.
    (lib.mkIf bindsTailnet {
      boot.kernel.sysctl = {
        "net.ipv4.ip_nonlocal_bind" = 1;
        "net.ipv6.ip_nonlocal_bind" = 1;
      };
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 80 ];
    })

    # Vhosts this edge fronts for non-edge hosts.
    {
      services.nginx.virtualHosts = lib.mapAttrs (_: backend: {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${meta.tailscaleIPs.${backend}}";
          proxyWebsockets = true;
        };
      }) cfg.proxy;
    }
  ];
}
