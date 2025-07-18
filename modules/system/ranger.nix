{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  environment.systemPackages = with pkgs; [
    wpa_supplicant
    waybar
    alacritty
    wofi
    nerd-fonts.jetbrains-mono
    firefox
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };
  };
  programs.hyprland.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;

  environment.variables.HOSTCLASS = lib.mkAfter "ranger";
}
