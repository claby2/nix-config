{ lib, config, ... }:
let cfg = config.hostclass.mac;
in {

  options.hostclass.mac = { enable = lib.mkEnableOption "mac hostclass"; };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkAfter "mac";

    # === PROGRAMS
    # NOTE: This should ideally be specified in ../../common/hostclass/base.nix
    # as programs.zsh.syntaxHighlighting.enable, however, it seems nix-darwin
    # is outdated so it uses this old name...
    programs.zsh.enableSyntaxHighlighting = true;
  };
}
