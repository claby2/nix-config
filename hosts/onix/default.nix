{ pkgs, config, modulesPath, meta, inputs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/system/server.nix
    ../../modules/homelab

  ];

  services.tailscale.enable = true;

  homelab.filebrowser = {
    enable = true;
    port = 3001;
    host = "filebrowser.edwardwibowo.com";
  };

  homelab.personal = {
    enable = true;
    host = "edwardwibowo.com";
  };

  homelab.amy = {
    enable = true;
    host = "amyqiao.com";
  };

  age.secrets.freshrss = {
    file = ./secrets/freshrss.age;
    owner = "freshrss";
    group = "freshrss";
  };
  homelab.freshrss = {
    enable = true;
    host = "freshrss.edwardwibowo.com";
    passwordFile = config.age.secrets.freshrss.path;
  };

  homelab.gitea = {
    enable = true;
    port = 3000;
    host = "git.edwardwibowo.com";
  };

  age.secrets.restic-repository.file = ./secrets/restic-repository.age;
  age.secrets.restic-password.file = ./secrets/restic-password.age;
  age.secrets.restic-environment.file = ./secrets/restic-environment.age;
  services.restic.backups.onix = {
    initialize = true;
    paths = [ "/var/lib" "/etc/ssh" ];
    pruneOpts =
      [ "--keep-within 7d" "--keep-monthly 12" "--keep-yearly 5" "--prune" ];
    extraBackupArgs = [ "--cache-dir" "/var/cache/restic-cache" ];
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
    };
    repositoryFile = config.age.secrets.restic-repository.path;
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-environment.path;
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
      configDir = "${homeDir}/nix-config";
    };
    users.claby2 = import ../../users/claby2;
  };

  system.stateVersion = "23.11";
}
