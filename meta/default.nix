{ ... }: {
  sshPublicKeys = {
    altaria =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBLd7fIMeCNRrQiPzW1ycYJ6wc3cu5l0PMdoXHWjCEu";
    applin =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIgpfqrD63csQegPzBTBPcNJbzgdsBkJhDm/w1uchE+";
    onix =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMfKUKBVy7gsRor30+S7CTCq5Vi5aIgOd+9iL1rDXdPN";
    browncs = # Key on Brown CS machine
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGF7r6WW7gCyUSPbPHFTOrqWZyCTd+h+DFkkKgs6jeWa";
  };
}
