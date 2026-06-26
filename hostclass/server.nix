{ pkgs, ... }:
{
  imports = [
    ./nixos.nix
    ../modules/homelab
  ];
  hostclasses = [ "server" ];

  environment = {
    systemPackages = with pkgs; [
      strace
      lsof
      tcpdump
      mtr
    ];
  };

  services.tailscale.useRoutingFeatures = "server";

  services.earlyoom.enable = true;
}
