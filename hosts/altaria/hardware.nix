{ ... }: {
  networking.hostName = "altaria";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
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
}
