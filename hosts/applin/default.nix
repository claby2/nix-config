{ config, inputs, ... }: {
  hostclass.mac = {
    enable = true;
    motd = builtins.readFile "${inputs.self}/hosts/applin/applin";
  };

  system.stateVersion = 6;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";

  # === SERVICES
  services.tailscale.enable = true;

  # === ENVIRONMENT
  environment.variables.TERM = "rxvt";

  # === USERS
  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };

  # === HOME
  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };
}
