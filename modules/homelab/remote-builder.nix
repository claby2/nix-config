{ config, lib, ... }:
let
  cfg = config.homelab.remoteBuilder;
in
{
  options.homelab.remoteBuilder = {
    enable = lib.mkEnableOption "remote nix builder";
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to use this machine as a remote builder.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.builder = {
      isSystemUser = true;
      group = "builder";
      shell = "/bin/sh";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
    users.groups.builder = { };
    nix.settings.extra-trusted-users = [ "builder" ];
  };
}
