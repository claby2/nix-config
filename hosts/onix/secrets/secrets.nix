let
  key =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMfKUKBVy7gsRor30+S7CTCq5Vi5aIgOd+9iL1rDXdPN";
in {
  "freshrss.age".publicKeys = [ key ];
  "restic-repository.age".publicKeys = [ key ];
  "restic-password.age".publicKeys = [ key ];
  "restic-environment.age".publicKeys = [ key ];
}
