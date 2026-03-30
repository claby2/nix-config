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
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # === ASSERTIONS
  assertions = [
    {
      assertion = pkgs.stdenv.isDarwin;
      message = "The 'darwin' hostclass can only be used on Darwin systems.";
    }
  ];

  # === ENVIRONMENT
  environment = {
    variables.HOSTCLASS = "darwin";
    systemPackages = with pkgs; [
      aerospace
      kitty
      terminal-notifier
      jankyborders
      pngpaste
    ];
  };

  # === PROGRAMS
  programs.zsh.enableSyntaxHighlighting = true;

  # === USERS
  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };
}
