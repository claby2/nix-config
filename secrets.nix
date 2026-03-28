let
  key = (import ./meta/default.nix { }).sshPublicKeys;
in
{

  # === Altaria
  "hosts/altaria/secrets/freshrss.age".publicKeys = [
    key.altaria
    key.applin
  ];
  "hosts/altaria/secrets/restic-environment.age".publicKeys = [
    key.altaria
    key.applin
  ];
  "hosts/altaria/secrets/restic-password.age".publicKeys = [
    key.altaria
    key.applin
  ];
  "hosts/altaria/secrets/restic-repository.age".publicKeys = [
    key.altaria
    key.applin
  ];
  "hosts/altaria/secrets/grafana-password.age".publicKeys = [
    key.altaria
    key.applin
  ];

  # === Onix
  "hosts/onix/secrets/gatus-environment.age".publicKeys = [
    key.onix
    key.applin
  ];
  "hosts/onix/secrets/grafana-password.age".publicKeys = [
    key.onix
    key.applin
  ];

}
