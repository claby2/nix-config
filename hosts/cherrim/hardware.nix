{ ... }: {
  networking.hostName = "cherrim";
  networking.networkmanager.enable = true;
  # Prevent host becoming unreachable on WiFi after some time.
  networking.networkmanager.wifi.powersave = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "xfs";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  # Raspberry Pi does not use GRUB
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
}
