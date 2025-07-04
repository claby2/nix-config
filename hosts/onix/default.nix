{ pkgs, config, modulesPath, meta, inputs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/system/server.nix
    ../../modules/homelab

  ];

  homelab.gitea = {
    enable = true;
    port = 3000;
    host = "git.onix.edwardwibowo.com";
  };

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "ext4";
  };

  networking.hostName = "onix";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  programs.zsh.loginShellInit = ''
    cat <<EOF
    ${builtins.readFile "${inputs.self}/hosts/onix/onix"}
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
      configDir = "${homeDir}/nix-dots";
    };
    users.claby2 = import ../../users/claby2;
  };

  system.stateVersion = "23.11";
}
