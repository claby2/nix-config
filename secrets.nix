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

  # === Cherrim
  "hosts/cherrim/secrets/step-ca-intermediate-key.age".publicKeys = [
    key.cherrim
    key.applin
  ];

  # === Applin
  # Root CA key: encrypted to applin only, so no server can ever decrypt it.
  # Used only to sign a new intermediate (see meta/ca).
  "hosts/applin/secrets/root-ca-key.age".publicKeys = [
    key.applin
  ];
}
