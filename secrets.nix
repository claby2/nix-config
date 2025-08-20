let key = (import ./meta/default.nix { }).sshPublicKeys;
in {

  # === Altaria
  "hosts/altaria/secrets/gatus-environment.age".publicKeys =
    [ key.altaria key.applin ];
  "hosts/altaria/secrets/grafana-password.age".publicKeys =
    [ key.altaria key.applin ];

  # === Onix
  "hosts/onix/secrets/freshrss.age".publicKeys = [ key.onix key.applin ];
  "hosts/onix/secrets/restic-environment.age".publicKeys =
    [ key.onix key.applin ];
  "hosts/onix/secrets/restic-password.age".publicKeys = [ key.onix key.applin ];
  "hosts/onix/secrets/restic-repository.age".publicKeys =
    [ key.onix key.applin ];
}
