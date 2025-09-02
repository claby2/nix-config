{ lib, pkgs, config, ... }:
let cfg = config.home.claby2;
in {
  options.home.claby2 = {
    enable = lib.mkEnableOption "claby2 home";
    homeDirectory = lib.mkOption { type = lib.types.str; };
    nixConfigDirectory = lib.mkOption { type = lib.types.str; };
    enableLinuxDesktop = lib.mkEnableOption "enable linux desktop";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.claby2 = { config, ... }: {
      home.username = "claby2";
      home.homeDirectory = cfg.homeDirectory;

      home.packages = with pkgs;
        [
          gnupg
          ripgrep
          neovim
          gcc
          nixfmt-classic
          nil
          fzf
          jq
          tokei
          nodePackages.prettier
          claude-code
          uv
          delta
          pyright
          patdiff
          mutagen
          nodejs # Need node so copilot works (via nvim)... and other stuff I guess.
        ] ++ lib.optionals cfg.enableLinuxDesktop [
          alacritty
          waybar
          wofi
          firefox
          nerd-fonts.jetbrains-mono
        ];

      home.file = {
        ".zshrc".source = config.lib.file.mkOutOfStoreSymlink
          "${cfg.nixConfigDirectory}/apps/zsh/zshrc";
        ".local/bin".source = config.lib.file.mkOutOfStoreSymlink
          "${cfg.nixConfigDirectory}/apps/scripts";
      };
      xdg.configFile = {
        "hladmin".source = config.lib.file.mkOutOfStoreSymlink
          "${cfg.nixConfigDirectory}/apps/hladmin";
        "nvim".source = config.lib.file.mkOutOfStoreSymlink
          "${cfg.nixConfigDirectory}/apps/nvim";
      } // lib.optionalAttrs cfg.enableLinuxDesktop {
        "hypr".source = config.lib.file.mkOutOfStoreSymlink
          "${cfg.nixConfigDirectory}/apps/hypr";
      };

      programs.git = {
        enable = true;
        userName = "Edward Wibowo";
        userEmail = "wibow9770@gmail.com";
        extraConfig = {
          init.defaultBranch = "main";
          credential.helper = "store";
          commit.gpgsign = true;
        };
        signing = { key = "5F7198C07D80B3B6815D687B194285BC07FDC3DA"; };
      };

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry.tty;
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      home.stateVersion = "25.05";
    };
  };
}
