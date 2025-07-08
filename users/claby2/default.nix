{ pkgs, config, homeDir, configDir, ... }: {
  home.username = "claby2";
  home.homeDirectory = homeDir;

  home.packages = with pkgs; [ ripgrep neovim gcc nixfmt-classic nil fzf ];

  home.file = {
    ".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/apps/zsh/zshrc";
  };
  xdg.configFile = {
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/apps/nvim";
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
}
