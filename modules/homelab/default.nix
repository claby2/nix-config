{ pkgs, ... }:
{
  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "The homelab module can only be used on NixOS (Linux) systems.";
    }
  ];
  imports = [
    ./gitea.nix
    ./personal.nix
    ./freshrss.nix
    ./amy.nix
    ./filebrowser.nix
    ./gatus.nix
    ./metrics.nix
    ./avge.nix
    ./remote-builder.nix
  ];
  services.nginx = {
    enable = true;
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
