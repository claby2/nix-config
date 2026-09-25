{
  config,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  users.motd = builtins.readFile ./onix;

  # === HOMELAB
  homelab = {
    hosting.silph-collector.internal = "onix.silph-collector";
    silph-collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
      };
    };
  };
}
