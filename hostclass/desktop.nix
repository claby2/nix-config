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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment = {
    systemPackages = with pkgs; [
      kitty
      fuzzel
      wlr-randr
      discord
      spotify
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Hint Electron/Chromium apps to run natively on Wayland.
    sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
