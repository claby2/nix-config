{
  config,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../modules/homelab
  ];
  system.stateVersion = "25.11";
  users.motd = builtins.readFile ./groudon;

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = {
      home = {
        SUBVOLUME = "/home";
        FSTYPE = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 10;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
        TIMELINE_LIMIT_YEARLY = 2;
      };

      root = {
        SUBVOLUME = "/";
        FSTYPE = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 10;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
        TIMELINE_LIMIT_YEARLY = 2;
      };
    };
  };

  # === HOMELAB
  homelab = {
    dns.entries = {
      "groudon.silph-collector" = config.homelab.silph.collector.port;
    };
    silph.collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
        temperature = { };
      };
    };
  };
}
