{ ... }: {
  imports = [
    ./gitea.nix
    ./personal.nix
    ./freshrss.nix
    ./amy.nix
    ./filebrowser.nix
    ./gatus.nix
  ];
  services.nginx.enable = true;
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
