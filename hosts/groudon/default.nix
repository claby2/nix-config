{
  pkgs,
  config,
  meta,
  ...
}:
{
  imports = [
    (import ../../hostclass/server.nix { motd = builtins.readFile ./groudon; })
    ./hardware.nix
  ];
  system.stateVersion = "25.11";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

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

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        meta.sshPublicKeys.applin
      ];
    };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
    };
  };

  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };
}
