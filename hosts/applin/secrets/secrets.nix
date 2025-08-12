let
  key =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIgpfqrD63csQegPzBTBPcNJbzgdsBkJhDm/w1uchE+";
in { "wireguard-private-key.age".publicKeys = [ key ]; }
