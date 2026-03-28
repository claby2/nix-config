{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./base.nix ];

  environment.variables.HOSTCLASS = lib.mkAfter "mac";

  # === MOTD
  environment.etc."motd".text = "TODO";

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
}
