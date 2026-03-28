{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.home.claby2;
in
{
  options.home.claby2 = {
    enable = lib.mkEnableOption "claby2 home";
    homeDirectory = lib.mkOption { type = lib.types.str; };
    nixConfigDirectory = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.claby2 =
      { config, ... }:
      {
        home = {
          username = "claby2";
          inherit (cfg) homeDirectory;

          packages = with pkgs; [
            gnupg
            ripgrep
            neovim
            gcc
            nixfmt
            nil
            fzf
            jq
            tokei
            nodePackages.prettier
            inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
            inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
            uv
            delta
            pyright
            yapf
            ruff
            patdiff
            mutagen
            nodejs # Need node so copilot works (via nvim)... and other stuff I guess.
            opencode
            comma
            nh
            nix-output-monitor
            clang-tools
            ccls
            stylua
          ];

          file = {
            ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigDirectory}/apps/zsh/zshrc";
            ".local/bin".source = config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigDirectory}/apps/scripts";
          };

          stateVersion = "25.05";
        };
        xdg.configFile = {
          "hladmin".source = config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigDirectory}/apps/hladmin";
          "nvim".source = config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigDirectory}/apps/nvim";
          "aerospace".source = config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigDirectory}/apps/aerospace";
        };

        programs.git = {
          enable = true;
          settings = {
            user.name = "Edward Wibowo";
            user.email = "wibow9770@gmail.com";
            init.defaultBranch = "main";
            credential.helper = "store";
            commit.gpgsign = true;
          };
          signing = {
            key = "5F7198C07D80B3B6815D687B194285BC07FDC3DA";
          };
        };

        services.gpg-agent = {
          enable = true;
          pinentry.package = pkgs.pinentry-curses;
        };

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

      };
  };
}
