{ pkgs, inputs, ... }:
{
  imports = [
    ./nixos.nix
  ];
  hostclasses = [ "desktop" ];

  # Launched from a TTY with `qtile start -b wayland`.
  services.xserver.windowManager.qtile.enable = true;
  hardware.graphics.enable = true;

  # Pair devices with `bluetoothctl`.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.dbus.packages = [ pkgs.swayosd ];
  systemd.packages = [ pkgs.swayosd ];
  systemd.services.swayosd-libinput-backend.wantedBy = [ "multi-user.target" ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment = {
    systemPackages = with pkgs; [
      kitty
      fuzzel
      mako
      libnotify
      wlr-randr
      swayosd
      discord
      # Spotify's wrapper unsets DISPLAY under NIXOS_OZONE_WL but never selects
      # the Wayland backend itself, so it exits immediately without this flag.
      (symlinkJoin {
        name = "spotify";
        paths = [ spotify ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/spotify --add-flags "--ozone-platform=wayland"
        '';
      })
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Hint Electron/Chromium apps to run natively on Wayland.
    sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
