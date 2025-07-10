{ config, meta, inputs, ... }: {
  imports = [ ../../modules/system/base.nix ];

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

  home-manager = {
    extraSpecialArgs = rec {
      inherit meta inputs;
      homeDir = config.users.users.claby2.home;
      configDir = "${homeDir}/nix-config";
    };
    users.claby2 = import ../../users/claby2;
  };

  environment.variables.TERM = "rxvt";
}
