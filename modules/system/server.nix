{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.variables.HOSTCLASS = lib.mkAfter "server";
}
