{ pkgs, config, modulesPath, meta, ... }: {
  imports =
    [ ./hardware.nix (modulesPath + "/installer/scan/not-detected.nix") ];
  hostclass.desktop.enable = true;

  system.stateVersion = "23.11";

  # === USERS
  users.users = {
    root = { openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ]; };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
    };
  };

  # === HOME
  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
    enableLinuxDesktop = true; # TODO: Deprecate this mayb
  };
}

