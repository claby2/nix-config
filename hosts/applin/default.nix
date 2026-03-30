{
  config,
  pkgs,
  ...
}:
{
  system.stateVersion = 6;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";
  environment.etc."motd".text = builtins.readFile ./applin;

  # === AGE
  # NOTE: age.identityPaths looks at ssh host keys, but not personal keys. So,
  # we must override age.identityPaths here.
  age = {
    identityPaths = [ "${config.users.users.claby2.home}/.ssh/id_ed25519" ];
    secrets = {
      altaria-restic-repository.file = ../altaria/secrets/restic-repository.age;
      altaria-restic-password.file = ../altaria/secrets/restic-password.age;
      altaria-restic-environment.file = ../altaria/secrets/restic-environment.age;
    };
  };

  # === ENVIRONMENT
  environment = {
    variables.TERM = "rxvt";
    systemPackages = [
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
  };
}
