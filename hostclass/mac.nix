{
  motd ? "",
}:
{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  hostclass.name = "mac";

  # === ASSERTIONS
  assertions = [
    {
      assertion = pkgs.stdenv.isDarwin;
      message = "The 'mac' hostclass can only be used on Darwin systems.";
    }
  ];

  # === MOTD
  environment.etc."motd".text = motd;

  # === ENVIRONMENT
  environment.systemPackages = with pkgs; [
    aerospace
    kitty
    terminal-notifier
    jankyborders
    pngpaste
  ];

  # === PROGRAMS
  programs.zsh.enableSyntaxHighlighting = true;

  # === USERS
  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };
}
