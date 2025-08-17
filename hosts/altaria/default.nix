{ pkgs, config, modulesPath, meta, inputs, homelab, ... }: {
  imports = [ ./hardware.nix (modulesPath + "/profiles/qemu-guest.nix") ];
  hostclass.server = {
    enable = true;
    motd = builtins.readFile "${inputs.self}/hosts/altaria/altaria";
  };

  system.stateVersion = "23.11";

  # === AGE
  age.secrets.gatus-environment.file = ./secrets/gatus-environment.age;

  # === SERVICES
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  # === HOMELAB
  homelab.gatus = let mkEndpoint = homelab.mkGatusEndpoint;
  in {
    enable = true;
    port = 3000;
    host = "gatus.edwardwibowo.com";
    endpoints = [
      (mkEndpoint "personal" "https://edwardwibowo.com")
      (mkEndpoint "filebrowser" "https://filebrowser.edwardwibowo.com")
      (mkEndpoint "freshrss" "https://freshrss.edwardwibowo.com")
      (mkEndpoint "git" "https://git.edwardwibowo.com")
      {
        name = "onix ssh";
        url = "ssh://onix.edwardwibowo.com:22";
        ssh = {
          username = "";
          password = "";
        };
        interval = "5m";
        conditions = [ "[CONNECTED] == true" "[STATUS] == 0" ];
        alerts = [{ type = "discord"; }];
      }
    ];
    environmentFile = config.age.secrets.gatus-environment.path;
    alerting.discord = {
      webhook-url = "$DISCORD_WEBHOOK_URL";
      default-alert = {
        send-on-resolved = true;
        failure-threshold = 1;
      };
    };
  };

  # === USERS
  users.users = {
    root = { openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ]; };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys =
        [ meta.sshPublicKeys.applin meta.sshPublicKeys.browncs ];
    };
  };

  # === HOME
  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };
}
