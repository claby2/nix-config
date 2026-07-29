_: {
  tailnetName = "tail983a17.ts.net";
  # Stable tailnet IPv4 addresses (`tailscale ip -4 <host>`).
  tailscaleIPs = {
    cherrim = "100.111.150.115";
  };
  # Source of truth for .internal DNS, served by dnsmasq on cherrim.
  # Maps internal domain -> host whose tailnet IP the record points at.
  # Add services on other hosts here (plus the host's IP above).
  internalDomains = {
    "grafana.internal" = "cherrim";
  };
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
