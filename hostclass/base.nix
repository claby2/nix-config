# Base hostclass should be cross-platform!
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

  # In the end, we want $HOSTCLASS to display the machine's "highest-level" hostclass,
  # meaning the one at the bottom of the inheritance chain with base being at the top.
  # We leverage nix's list merging semantics whereby multiple definitions of `types.listOf`
  # variable are merged with list concatenation, so the most specific hostclass can be
  # defined last and take precedence.
  # See: https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html#composed-types
  options.hostclasses = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "base" ];
    description = "Ordered list of active hostclasses, most specific last.";
  };

  config = {

    nix.settings.extra-trusted-users = [ "claby2" ];

    # Include the git commit hash (and also whether it was dirty at the time of
    # building) in the configuration revision. This shows up when running
    # `nixos-version --configuration-revision` on NixOS or `darwin-version
    # --configuration-revision` on darwin.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or "unknown";
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = "nix-command flakes";

    environment = {
      variables.HOSTCLASS = lib.last config.hostclasses; # LAST hostclass in list takes precedence
      systemPackages = with pkgs; [
        j
        git
        vim
        wget
        htop
        tree
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
        inputs.hladmin.packages."${stdenv.hostPlatform.system}".default
      ];
      variables.EDITOR = "vim";
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };

    services.tailscale.enable = true;

    home.claby2 = rec {
      enable = true;
      homeDirectory = config.users.users.claby2.home;
      nixConfigDirectory = "${homeDirectory}/nix-config";
    };
  };
}
