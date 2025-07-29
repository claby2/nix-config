{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal & Shell
    alacritty

    # Window Manager & Desktop
    waybar
    wofi

    # Applications
    firefox

    # Fonts
    nerd-fonts.jetbrains-mono
  ];

  # Desktop-specific configurations can go here
  # e.g., waybar config, alacritty config, etc.
}

