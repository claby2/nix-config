{ pkgs, config, modulesPath, meta, inputs, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/system/ranger.nix
  ];

  boot.initrd.availableKernelModules =
    [ "ufshcd_pci" "xhci_pci" "uas" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/16631731-a80f-4741-a968-94eb1f7bb15d";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/58F0-A6A4";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/a70859c3-3cea-4f8a-882e-16a5d0c468c8"; }];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "trubbish";
  networking.wireless.enable = true;

  time.timeZone = "America/New_York";

  powerManagement.enable = true;

  programs.zsh.loginShellInit = ''
    cat <<EOF
    ${builtins.readFile "${inputs.self}/hosts/trubbish/trubbish"}
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
