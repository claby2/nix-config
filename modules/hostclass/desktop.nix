{ pkgs, lib, config, ... }:
let cfg = config.hostclass.desktop;
in {
  imports = [ ./base.nix ];

  options.hostclass.desktop = {
    enable = lib.mkEnableOption "desktop hostclass";
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    environment.systemPackages = with pkgs; [ wpa_supplicant ];

    programs.uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
    programs.hyprland.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry.tty;
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    services.libinput.enable = true;

    networking.wireless.enable = true;

    environment.variables.HOSTCLASS = lib.mkAfter "desktop";
  };
}

