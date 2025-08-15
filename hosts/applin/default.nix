{ config, inputs, ... }: {
  hostclass.mac = {
    enable = true;
    motd = builtins.readFile "${inputs.self}/hosts/applin/applin";
  };

  services.tailscale.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };

  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };

  environment.variables.TERM = "rxvt";
}
