{
  pkgs,
  config,
  modulesPath,
  meta,
  inputs,
  ...
}:
{
  imports = [
    ../../hostclass/server.nix
    ./hardware.nix
  ];
  system.stateVersion = "23.11";
  nix.settings.experimental-features = "nix-command flakes";

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
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
