_: {
  tailnetName = "tail983a17.ts.net";
  # Stable tailnet IPv4 addresses (`tailscale ip -4 <host>`).
  tailscaleIPs = {
    cherrim = "100.111.150.115";
  };
  # TLD for homelab-internal DNS; the zone itself is derived from each
  # host's homelab.dns.entries (see modules/homelab/dns.nix). Tailscale
  # split DNS in the admin console routes this TLD to the dns server
  # host's tailnet IP — update it there too if this ever changes.
  internalTld = "internal";
  sshPublicKeys = {
    altaria = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIg8SRUjPyiBA/aucB/p5ZroCQ+peJsdCeQF46LX5S2u";
    applin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIgpfqrD63csQegPzBTBPcNJbzgdsBkJhDm/w1uchE+";
    onix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID24bidyqgItpGbLThELV454VCtYKZdKGvTIbHsindbK";
    groudon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3YpqPdgTT7obDKwUqyxZMClxcpuFRB6Pl8Kww05jyf";
    cherrim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWnEbFFp+O3Y+6kmudC9DnmWylgkABxLk2gbXFAT+vK";
    browncs = # Key on Brown CS machine
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGF7r6WW7gCyUSPbPHFTOrqWZyCTd+h+DFkkKgs6jeWa";
  };
}
