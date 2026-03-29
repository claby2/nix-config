{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "groudon";
  networking.networkmanager.enable = true;

  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "uas"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "nomodeset" ]; # GPU doesn't work right now, so setting this :(
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ceb92813-ddf0-4333-836c-f65e40f045c8";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@root"
      ];
    };
    "/.snapshots" = {
      device = "/dev/disk/by-uuid/ceb92813-ddf0-4333-836c-f65e40f045c8";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@snapshots"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/ceb92813-ddf0-4333-836c-f65e40f045c8";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@home"
      ];
    };
    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/ceb92813-ddf0-4333-836c-f65e40f045c8";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@home-snapshots"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/ceb92813-ddf0-4333-836c-f65e40f045c8";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@nix"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/49BF-025F";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/0e726db1-62d5-42e1-b4fb-540d56faa7c2"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableAllFirmware = true;
  };
}
