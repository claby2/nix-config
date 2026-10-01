{
  meta,
  config,
  lib,
  inputs,
  ...
}:
# Private ACME CA (step-ca) for the internal TLD, serving the tailnet at
# https://<tailnet IP>:<port>. Addressed by IP rather than a name under the
# TLD so it needs no DNS record of its own (the root permits tailnet IPs).
# Hosts get certs for their internal names over ACME HTTP-01: step-ca
# resolves the name via the internal DNS server and fetches the challenge
# from that host's nginx on port 80.
let
  cfg = config.homelab.ca;
  tld = meta.internalTld;
  me = config.networking.hostName;
  ip = meta.tailscaleIPs.${me};
  # Hosts across the flake that run the CA (at most one; asserted below).
  caHosts = lib.filterAttrs (_: h: h.config.homelab.ca.server.enable) inputs.self.nixosConfigurations;
  # agenix decrypts the key root-only, which step-ca's DynamicUser can't
  # read. LoadCredential (below) has systemd copy it at start into a
  # directory only this service can read. Spelled out because ca.json is
  # static and can't expand $CREDENTIALS_DIRECTORY.
  keyCredential = "/run/credentials/step-ca.service/intermediate_key";
in
{
  options.homelab.ca.server = {
    enable = lib.mkEnableOption "step-ca ACME server for the .${tld} zone";
    port = lib.mkOption {
      type = lib.types.port;
    };
    intermediateKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the intermediate CA's private key (an agenix secret).";
    };
  };

  options.homelab.ca.acmeServer = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    readOnly = true;
    default =
      if caHosts == { } then
        null
      else
        let
          host = lib.head (lib.attrNames caHosts);
          port = caHosts.${host}.config.homelab.ca.server.port;
        in
        "https://${meta.tailscaleIPs.${host}}:${toString port}/acme/acme/directory";
    description = "ACME directory URL of the host running homelab.ca.server, if any.";
  };

  config = lib.mkIf cfg.server.enable {
    assertions = [
      {
        # step-ca resolves challenge names through this host's dnsmasq.
        assertion = config.homelab.dns.server.enable;
        message = "homelab.ca.server on ${me} requires homelab.dns.server on the same host";
      }
      {
        assertion = lib.length (lib.attrNames caHosts) == 1;
        message = "homelab.ca.server is enabled on more than one host: ${toString (lib.attrNames caHosts)}";
      }
    ];

    services.step-ca = {
      enable = true;
      address = ip;
      inherit (cfg.server) port;
      extraArgs = [ "--resolver=${ip}:53" ];
      settings = {
        root = "${meta.ca.root}";
        crt = "${meta.ca.intermediate}";
        key = keyCredential;
        dnsNames = [ ip ];
        db = {
          type = "badgerv2";
          dataSource = "/var/lib/step-ca/db";
        };
        authority = {
          # No issuance policy: the root's name constraints already limit
          # certs to the internal TLD and tailnet IPs, and HTTP-01 only
          # passes for names the internal DNS server resolves. An exact
          # allowlist would force redeploying this host before any new name.
          provisioners = [
            {
              type = "ACME";
              name = "acme";
              challenges = [ "http-01" ];
              # Longer than security.acme's 30-day renewal window.
              claims = {
                defaultTLSCertDuration = "2160h";
                maxTLSCertDuration = "2160h";
              };
            }
          ];
        };
      };
    };

    systemd.services.step-ca = {
      serviceConfig.LoadCredential = [ "intermediate_key:${cfg.server.intermediateKeyFile}" ];
      # Bind the tailnet IP even if tailscale0 is not up yet.
      after = [ "tailscaled.service" ];
    };

    # mkDefault: hosting.nix sets the same value when nginx binds the tailnet.
    boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = lib.mkDefault 1;

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ cfg.server.port ];
  };
}
