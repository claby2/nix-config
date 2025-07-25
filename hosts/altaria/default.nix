{ pkgs, config, modulesPath, meta, inputs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/system/server.nix
    ../../modules/homelab

  ];

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
