{ config, inputs, ... }: {
  hostclass.mac.enable = true;

  services.tailscale.enable = true;

  programs.zsh.loginShellInit = ''
    cat <<EOF
    ${builtins.readFile "${inputs.self}/hosts/applin/applin"}
    EOF
  '';

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.claby2 = {
    home = "/Users/claby2";
    name = "claby2";
  };

  home.claby2 = rec {
    enable = true;
    homeDirectory = config.users.users.claby2.home;
    nixConfigDirectory = "${homeDirectory}/nix-config";
  };

  environment.variables.TERM = "rxvt";
}
