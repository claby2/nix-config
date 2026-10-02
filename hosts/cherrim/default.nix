{ config, pkgs, ... }:
let
  artwork =
    name: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${name}.png";
      inherit hash;
    };
in
{
  imports = [
    ./hardware.nix
  ];
  system.stateVersion = "26.11";
  users.motd = builtins.readFile ./cherrim;

  # === AGE
  age.secrets = {
    step-ca-intermediate-key.file = ./secrets/step-ca-intermediate-key.age;
  };

  # === HOMELAB
  homelab = {
    dns.server.enable = true;
    ca.server = {
      enable = true;
      port = 8443;
      intermediateKeyFile = config.age.secrets.step-ca-intermediate-key.path;
    };
    hosting = {
      silph-server.internal = "silph";
      silph-collector.internal = "cherrim.silph-collector";
    };
    silph-collector = {
      enable = true;
      port = 9100;
      metrics = {
        cpu = { };
        memory = { };
        disk = { };
        temperature = { };
      };
    };
    silph-server = {
      enable = true;
      port = 8080;
      targets = {
        cherrim = {
          url = "http://cherrim.silph-collector.internal";
          icon = artwork "421-sunshine" "sha256-PkiAjynFO1ce3DWbVQyaa13SLj060zIoK61UFJFGYnM=";
        };
        altaria = {
          url = "http://altaria.silph-collector.internal";
          icon = artwork "334" "sha256-F+FW5MIA0o+TGZVQ+gt+FadJ9nunFBgpb1Gb5nmijF0=";
        };
        groudon = {
          url = "http://groudon.silph-collector.internal";
          icon = artwork "383" "sha256-v2pDNNakmvMjlsnRVehnoWmUOf9zwou22tFd1GhLRGE=";
        };
      };
    };
  };
}
