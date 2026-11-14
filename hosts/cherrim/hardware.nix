{ lib, pkgs, inputs, ... }: {
  # Raspberry Pi 4 support: pinned RPi kernel and WiFi/Bluetooth firmware.
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  networking.hostName = "cherrim";
  networking.networkmanager.enable = true;
  # Prevent host becoming unreachable on WiFi after some time.
  networking.networkmanager.wifi.powersave = false;

  # wpa_supplicant 2.12 never connects with the Pi's brcmfmac firmware-offloaded
  # handshake: it waits for a "port authorized" event the driver doesn't send,
  # then times out. Keep 2.11 until that's fixed upstream.
  # https://github.com/TooTallNate/boompi/pull/10
  # https://github.com/raspberrypi/linux/issues/7634
  nixpkgs.overlays = [
    (final: prev: {
      wpa_supplicant =
        inputs.nixpkgs-wpa-supplicant.legacyPackages.${prev.stdenv.hostPlatform.system}.wpa_supplicant;
    })
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  # Raspberry Pi does not use GRUB
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
}
