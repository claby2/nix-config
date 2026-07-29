{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./base.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
  ];
  hostclasses = [ "darwin" ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  assertions = [
    {
      assertion = pkgs.stdenv.isDarwin;
      message = "The 'darwin' hostclass can only be used on Darwin systems.";
    }
  ];

  environment = {
    # tailscaled-on-macOS can't install split DNS into the system resolver,
    # so route the .internal TLD to MagicDNS explicitly (same workaround
    # nix-darwin's tailscale module uses for ts.net).
    etc."resolver/internal".text = "nameserver 100.100.100.100";
    systemPackages = with pkgs; [
      aerospace
      kitty
      terminal-notifier
      jankyborders
      pngpaste
    ];
  };

  programs.zsh.enableSyntaxHighlighting = true;

  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };
}
