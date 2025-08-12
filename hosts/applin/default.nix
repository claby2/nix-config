{ config, meta, inputs, ... }: {
  imports = [ ../../modules/system/base.nix ];

  programs.zsh.loginShellInit = ''
    cat <<EOF
    ${builtins.readFile "${inputs.self}/hosts/applin/applin"}
    EOF
  '';

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };

  age.secrets.wireguard-private-key.file = ./secrets/wireguard-private-key.age;
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.100.0.2/24" ];
      dns = [ "10.100.0.1" ];
      privateKeyFile = config.age.secrets.wireguard-private-key.path;
      peers = [{
        publicKey = "qIFR2OBIDgCsVa8vdKHNUGoYfKvDphyacvSS5ZQznCI=";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "altaria.edwardwibowo.com:51820";
        persistentKeepalive = 25;
      }];
    };
  };

  home-manager = {
    extraSpecialArgs = rec {
      inherit meta inputs;
      homeDir = config.users.users.claby2.home;
      configDir = "${homeDir}/nix-config";
    };
    users.claby2 = import ../../users/claby2;
  };

  environment.variables.TERM = "rxvt";
}
