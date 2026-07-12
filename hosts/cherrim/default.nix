{ ... }: {
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "26.11";
  users.motd = builtins.readFile ./cherrim;
}
