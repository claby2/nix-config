{ pkgs, config, modulesPath, meta, inputs, homelab, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/system/server.nix
    ../../modules/homelab

  ];

  age.secrets.gatus-environment.file = ./secrets/gatus-environment.age;
  homelab.gatus = let mkEndpoint = homelab.mkGatusEndpoint;
  in {
    enable = true;
    port = 3000;
    host = "gatus.edwardwibowo.com";
    endpoints = [
      (mkEndpoint "personal" "https://edwardwibowo.com")
      (mkEndpoint "filebrowser" "https://filebrowser.edwardwibowo.com")
      (mkEndpoint "freshrss" "https://freshrss.edwardwibowo.com")
      (mkEndpoint "git" "https://git.edwardwibowo.com")
      {
        name = "onix ssh";
        url = "ssh://onix.edwardwibowo.com:22";
        ssh = {
          username = "";
          password = "";
        };
        interval = "5m";
        conditions = [ "[CONNECTED] == true" "[STATUS] == 0" ];
        alerts = [{ type = "discord"; }];
      }
    ];
    environmentFile = config.age.secrets.gatus-environment.path;
    alerting.discord = {
      webhook-url = "$DISCORD_WEBHOOK_URL";
      default-alert = {
        send-on-resolved = true;
        failure-threshold = 1;
      };
    };
  };

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules =
    [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "xfs";
  };
  swapDevices = [{ device = "/dev/sda2"; }];

  networking.hostName = "altaria";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 51820 ];
  };

  # WireGuard VPN Server Configuration
  age.secrets.wireguard-private-key.file = ./secrets/wireguard-private-key.age;
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp1s0 -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp1s0 -j MASQUERADE
    '';
    privateKeyFile = config.age.secrets.wireguard-private-key.path;

    peers = [{
      name = "applin";
      publicKey = "SPdR+2bdWecL5wF/oPuppZnMOG34Rd6/QPpDZEWEch0=";
      allowedIPs = [ "10.100.0.2/32" ];
    }];
  };

  programs.zsh.loginShellInit = ''
    cat <<EOF
    ${builtins.readFile "${inputs.self}/hosts/altaria/altaria"}
    EOF
  '';

  users.users = {
    root = { openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ]; };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
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

  system.stateVersion = "23.11";
}
