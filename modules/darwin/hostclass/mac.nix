{ pkgs, lib, config, ... }:
let cfg = config.hostclass.mac;
in {

  options.hostclass.mac = {
    enable = lib.mkEnableOption "mac hostclass";
    motd = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkAfter "mac";
    # NOTE: I think nix-darwin does not have `users.motd` option, so doing setting motd manually here.
    environment.etc."motd".text = cfg.motd;
    environment.systemPackages = with pkgs; [ aerospace kitty ];

    # === PROGRAMS
    # NOTE: This should ideally be specified in ../../common/hostclass/base.nix
    # as programs.zsh.syntaxHighlighting.enable, however, it seems nix-darwin
    # is outdated so it uses this old name...
    programs.zsh.enableSyntaxHighlighting = true;
  };
}
