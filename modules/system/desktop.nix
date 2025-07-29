{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  # Essential system packages for wireless
  environment.systemPackages = with pkgs; [
    wpa_supplicant
  ];

  # Wayland compositor and session management
  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };
  programs.hyprland.enable = true;

  # Audio system
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Input device management
  services.libinput.enable = true;

  # Enable networking for wireless
  networking.wireless.enable = true;

  environment.variables.HOSTCLASS = lib.mkAfter "desktop";
}

