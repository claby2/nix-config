{ pkgs, config, meta, ... }: {
  imports = [ ./hardware.nix ];

  environment.systemPackages = with pkgs; [ git vim wget htop gnupg ];
  environment.variables.EDITOR = "vim";

  networking.hostName = "onix";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry.tty;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = { vim = "nvim"; };
  };
  users.users = {
    root = { openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ]; };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
    };
  };

  system.stateVersion = "23.11";
  home-manager = {
    extraSpecialArgs = let homeDir = config.users.users.claby2.home;
    in {
      inherit meta homeDir;
      configDir = "${homeDir}/nix-dots";
    };
    users.claby2 = import ./home.nix;
  };
}
