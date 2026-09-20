{
  pkgs,
  meta,
  inputs,
  ...
}:
{
  imports = [
    ./base.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
  ];
  hostclasses = [ "nixos" ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  assertions = [
    {
      assertion = pkgs.stdenv.hostPlatform.isLinux;
      message = "The 'nixos' hostclass can only be used on NixOS (Linux) systems.";
    }
  ];

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    zsh.syntaxHighlighting.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        # Without this, sshd still offers keyboard-interactive via PAM,
        # which effectively re-enables password login.
        KbdInteractiveAuthentication = false;
        AllowAgentForwarding = true;
      };
    };
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        meta.sshPublicKeys.applin
      ];
    };
    claby2 = {
      shell = pkgs.zsh;
      isNormalUser = true;
      home = "/home/claby2";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [ meta.sshPublicKeys.applin ];
    };
  };
}
