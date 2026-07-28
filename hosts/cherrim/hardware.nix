{ lib, pkgs, inputs, ... }: {
  # Raspberry Pi 4 support: pinned RPi kernel and WiFi/Bluetooth firmware.
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  networking.hostName = "cherrim";
  networking.networkmanager.enable = true;
  # Prevent host becoming unreachable on WiFi after some time.
  networking.networkmanager.wifi.powersave = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  # Raspberry Pi does not use GRUB
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
}
