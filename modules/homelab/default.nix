{ ... }: {
  imports = [ ./gitea.nix ./personal.nix ];
  services.nginx.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "wibow9770@gmail.com";
  };
}
