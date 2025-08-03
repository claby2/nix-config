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

  home-manager = {
    extraSpecialArgs = rec {
      inherit meta inputs;
      homeDir = config.users.users.claby2.home;
      configDir = "${homeDir}/nix-config";
    };
    users.claby2 = import ../../users/claby2;
  };

  environment.variables.TERM = "rxvt";

  # WireGuard VPN Client Configuration
  age.secrets.wireguard-private-key.file = ./secrets/wireguard-private-key.age;
  networking.wireguard.enabe = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];
    listenPort = 51820;
    privateKeyFile = config.age.secrets.wireguard-private-key.path;

    peers = [{
      # altaria server
      publicKey = "2Z+9N8m6HvFatS68CqvGYxmKcv7VuTRFvakt8kRAmTU=";
      allowedIPs = [ "0.0.0.0/0" ];
      endpoint = "altaria.edwardwibowo.com:51820";
      persistentKeepalive = 25;
    }];
  };
}
