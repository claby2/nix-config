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
  "hosts/altaria/secrets/samba-password.age".publicKeys = [
    key.altaria
    key.applin
  ];
  "hosts/altaria/secrets/gatus-environment.age".publicKeys = [
    key.altaria
    key.applin
  ];
}
