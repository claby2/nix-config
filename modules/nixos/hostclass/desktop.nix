{ pkgs, lib, config, ... }:
let cfg = config.hostclass.desktop;
in {
  options.hostclass.desktop = {
    enable = lib.mkEnableOption "desktop hostclass";
  };

  config = lib.mkIf cfg.enable {
    hostclass.base.enable = true;

    # === ENVIRONMENT
    environment.variables.HOSTCLASS = lib.mkAfter "desktop";
    environment.systemPackages = with pkgs; [ wpa_supplicant ];

    # === PROGRAMS
    programs.zsh.syntaxHighlighting.enable = true;
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

    # === SERVICES
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    services.libinput.enable = true;

    # === NETWORKING
    networking.wireless.enable = true;
  };
}

