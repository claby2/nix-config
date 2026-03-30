{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../modules/home
  ];

  # Include the git commit hash (and also whether it was dirty at the time of
  # building) in the configuration revision. This shows up when running
  # `nixos-version --configuration-revision` on NixOS or `darwin-version
  # --configuration-revision` on darwin.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or "unknown";

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = "nix-command flakes";

  # === ENVIRONMENT
  environment = {
    variables.HOSTCLASS = lib.mkDefault "base";
    systemPackages = with pkgs; [
      git
      vim
      wget
      htop
      tree
      mtr
      inputs.agenix.packages."${stdenv.hostPlatform.system}".default
      inputs.hladmin.packages."${stdenv.hostPlatform.system}".default
    ];
    variables.EDITOR = "vim";
  };

  # === PROGRAMS
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # === SERVICES
  services.tailscale.enable = true;

  # === HOME
  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };
}
