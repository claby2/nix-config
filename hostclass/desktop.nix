{ pkgs, inputs, ... }:
{
  imports = [
    ./nixos.nix
  ];
  hostclasses = [ "desktop" ];

  # Launched from a TTY with `qtile start -b wayland`.
  services.xserver.windowManager.qtile = {
    enable = true;
    # Fixes a crash after all outputs disappear, e.g. turning off the only
    # monitor: https://github.com/qtile/qtile/issues/6041. Drop once fixed.
    # `overrideAttrs` rather than `overridePythonAttrs`, which drops the
    # `.override` the module calls on this.
    package = pkgs.python3.pkgs.qtile.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../patches/qtile-zero-outputs.patch ];
    });
  };
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.steam.enable = true;
  # Prefix a game's Steam launch options with `gamemoderun %command%`.
  programs.gamemode.enable = true;
  # Required for gamemode to renice games.
  users.users.claby2.extraGroups = [ "gamemode" ];

  # Provides the file chooser that apps like waytrogen open through D-Bus.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };
  # Without a display manager nothing starts graphical-session.target, which
  # can't be started directly, so portals never come up. qtile starts and stops
  # this target instead (see apps/qtile/config.py), pulling it in for the
  # session's lifetime.
  systemd.user.targets.qtile-session = {
    description = "qtile session";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  services.dbus.packages = [ pkgs.swayosd ];
  systemd.packages = [ pkgs.swayosd ];
  systemd.services.swayosd-libinput-backend.wantedBy = [ "multi-user.target" ];

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
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
      xdg-utils
      grim
      slurp
      wl-clipboard
      waytrogen
      swaybg
      discord
      obsidian
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
