{ ... }: {
  imports = [
    ./gitea.nix
    ./personal.nix
    ./freshrss.nix
    ./amy.nix
    ./filebrowser.nix
    ./gatus.nix
    ./metrics.nix
  ];
  services.nginx = {
    enable = true;
    # Default virtual host that catches all unmatched requests
    # Returns 444 to drop connections without sending a response
    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      locations."/" = { return = "444"; };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "wibow9770@gmail.com";
  };

  _module.args.homelab.mkGatusEndpoint = name: url: {
    inherit name url;
    interval = "5m";
    conditions = [ "[STATUS] == 200" ];
    alerts = [{ type = "discord"; }];
  };
}
