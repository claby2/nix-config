{ pkgs, inputs, ... }:
{
  assertions = [
    {
      assertion = pkgs.stdenv.hostPlatform.isLinux;
      message = "The homelab module can only be used on NixOS (Linux) systems.";
    }
  ];
  imports = [
    # Layers: how services are exposed on this host and found on the tailnet.
    ./hosting.nix
    ./dns.nix
    # Services: daemon config only; each registers a vhost fragment with
    # hosting.nix and reads its own address back from there.
    ./services/gitea.nix
    ./services/personal.nix
    ./services/freshrss.nix
    ./services/files.nix
    ./services/gatus.nix
    ./services/silph-collector.nix
    ./services/silph-server.nix
    inputs.silph.nixosModules.default
  ];
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    # Default virtual host that catches all unmatched requests
    # Returns 444 to drop connections without sending a response
    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      locations."/" = {
        return = "444";
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "wibow9770@gmail.com";
  };
}
