{
  config,
  ...
}:
let
  endpoint = name: url: { inherit name url; };
in
{
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  users.motd = builtins.readFile ./onix;

  # === AGE
  age.secrets = {
    gatus-environment.file = ./secrets/gatus-environment.age;
  };

  # === HOMELAB
  homelab = {
    dns.entries = {
      "onix.prometheus" = config.homelab.metrics.prometheus.port;
      "onix.silph-collector" = config.homelab.silph.collector.port;
    };
    silph.collector = {
      enable = true;
      port = 9100;
    };
    metrics.prometheus = {
      enable = true;
      port = 3002;
      nodeExporterPort = 3003;
    };
    gatus = {
      enable = true;
      port = 3000;
      host = "gatus.edwardwibowo.com";
      endpoints = [
        (endpoint "personal" "https://edwardwibowo.com")
        (endpoint "filebrowser" "https://filebrowser.edwardwibowo.com")
        (endpoint "freshrss" "https://freshrss.edwardwibowo.com")
        (endpoint "git" "https://git.edwardwibowo.com")
      ];
      sshEndpoints = [
        (endpoint "altaria ssh" "ssh://altaria.edwardwibowo.com:22")
        (endpoint "altaria tailscale ssh" "ssh://altaria:22")
        (endpoint "groudon tailscale ssh" "ssh://groudon:22")
      ];
      environmentFile = config.age.secrets.gatus-environment.path;
    };
  };
}
