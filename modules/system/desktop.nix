{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

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
}

