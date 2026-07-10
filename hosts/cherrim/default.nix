{ ... }: {
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "26.11";
  nix.settings.extra-trusted-users = [ "claby2" ];
  users.motd = builtins.readFile ./cherrim;
}
