{ pkgs, ... }:
{
  imports = [
    ./nixos.nix
    ../modules/homelab
  ];

  environment = {
    variables.HOSTCLASS = "server";
    systemPackages = with pkgs; [
      strace
      lsof
      tcpdump
      mtr
    ];
  };

  # === SERVICES
  services.tailscale.useRoutingFeatures = "server";
}
