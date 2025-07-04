{ config, pkgs, configDir, meta, ... }: {
  home.username = "claby2";
  home.homeDirectory = "/home/claby2";
  home.packages = with pkgs; [ ripgrep strace lsof neovim gcc nixfmt-classic ];

  home.file = {
    ".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/apps/zsh/zshrc";
  };
  xdg.configFile = {
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/apps/nvim";
  };

  programs.git = meta.programs.git;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry.tty;
  };

  home.stateVersion = "25.05";
}
