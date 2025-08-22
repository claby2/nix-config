{ config, inputs, pkgs, ... }: {
  hostclass.mac = {
    enable = true;
    motd = builtins.readFile "${inputs.self}/hosts/applin/applin";
  };

  system.stateVersion = 6;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";

  # === AGE
  # NOTE: age.identityPaths looks at ssh host keys, but not personal keys. So,
  # we must override age.identityPaths here.
  age.identityPaths = [ "${config.users.users.claby2.home}/.ssh/id_ed25519" ];
  age.secrets.onix-restic-repository.file =
    ../onix/secrets/restic-repository.age;
  age.secrets.onix-restic-password.file = ../onix/secrets/restic-password.age;
  age.secrets.onix-restic-environment.file =
    ../onix/secrets/restic-environment.age;

  # === SERVICES
  services.tailscale.enable = true;

  # === ENVIRONMENT
  environment.variables.TERM = "rxvt";
  environment.systemPackages = [
    # NOTE: We can take advantage of the fact that applin has access to onix's
    # restic secrets and create a wrapper script.
    (pkgs.writeScriptBin "restic-onix" ''
      set -a
      source ${config.age.secrets.onix-restic-environment.path}
      RESTIC_PASSWORD_FILE=${config.age.secrets.onix-restic-password.path}
      RESTIC_REPOSITORY_FILE=${config.age.secrets.onix-restic-repository.path}

      exec ${pkgs.restic}/bin/restic "$@"
    '')
  ];

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
