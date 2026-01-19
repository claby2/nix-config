{
  config,
  inputs,
  pkgs,
  ...
}:
{
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
  age.secrets.altaria-restic-repository.file = ../altaria/secrets/restic-repository.age;
  age.secrets.altaria-restic-password.file = ../altaria/secrets/restic-password.age;
  age.secrets.altaria-restic-environment.file = ../altaria/secrets/restic-environment.age;

  # === SERVICES
  services.tailscale.enable = true;

  # === ENVIRONMENT
  environment.variables.TERM = "rxvt";
  environment.systemPackages = [
    # NOTE: We can take advantage of the fact that applin has access to altaria's
    # restic secrets and create a wrapper script.
    (pkgs.writeScriptBin "restic-altaria" ''
      set -a
      source ${config.age.secrets.altaria-restic-environment.path}
      RESTIC_PASSWORD_FILE=${config.age.secrets.altaria-restic-password.path}
      RESTIC_REPOSITORY_FILE=${config.age.secrets.altaria-restic-repository.path}

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
