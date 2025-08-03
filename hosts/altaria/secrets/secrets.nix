let
  key =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBLd7fIMeCNRrQiPzW1ycYJ6wc3cu5l0PMdoXHWjCEu";
in {
  "gatus-environment.age".publicKeys = [ key ];
  "wireguard-private-key.age".publicKeys = [ key ];
}
