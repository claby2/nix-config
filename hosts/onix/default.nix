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
    hosting = {
      silph-collector.internal = "onix.silph-collector";
      gatus.internal = "gatus";
    };
    silph-collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
      };
    };
    gatus = {
      enable = true;
      port = 3000;
      endpoints = [
        (endpoint "personal" "https://edwardwibowo.com")
        (endpoint "freshrss" "https://freshrss.edwardwibowo.com")
        (endpoint "git" "https://git.edwardwibowo.com")
      ];
      sshEndpoints = [
        (endpoint "altaria ssh" "ssh://altaria.edwardwibowo.com:22")
        (endpoint "altaria tailscale ssh" "ssh://altaria:22")
        (endpoint "groudon tailscale ssh" "ssh://groudon:22")
      ];
      manualEndpoints = [
        {
          name = "altaria files (smb)";
          url = "tcp://altaria:445";
          interval = "5m";
          conditions = [ "[CONNECTED] == true" ];
          alerts = [ { type = "discord"; } ];
        }
      ];
      environmentFile = config.age.secrets.gatus-environment.path;
    };
  };
}
