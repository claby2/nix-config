{ config, ... }: {
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "26.11";
  users.motd = builtins.readFile ./cherrim;

  # === HOMELAB
  homelab = {
    dns.server.enable = true;
    hosting = {
      silph-server.internal = "silph";
      silph-collector.internal = "cherrim.silph-collector";
    };
    silph-collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
        temperature = { };
      };
    };
    silph-server = {
      enable = true;
      port = 8080;
      targets = {
        cherrim = "http://cherrim.silph-collector.internal";
        onix = "http://onix.silph-collector.internal";
        altaria = "http://altaria.silph-collector.internal";
        groudon = "http://groudon.silph-collector.internal";
      };
    };
  };
}
