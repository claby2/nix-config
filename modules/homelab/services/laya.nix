{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.homelab.laya;

  # Upstream's package.nix hardcodes torch-bin, the prebuilt CUDA wheel: unfree,
  # a multi-GB download, and not on cache.nixos.org. Our hosts have no working
  # GPU, so swap in nixpkgs' CPU torch, which Hydra builds and caches.
  python = pkgs.python3.override {
    packageOverrides = _: prev: { torch-bin = prev.torch; };
  };
  laya = pkgs.callPackage "${inputs.laya}/nix/package.nix" {
    python3 = python;
    python3Packages = python.pkgs;
  };
in
{
  options.homelab.laya = {
    enable = lib.mkEnableOption "laya";
    port = lib.mkOption { type = lib.types.port; };
    threads = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        Cap on torch intra-op threads. Keep at or below the host's physical
        core count; null leaves torch's default.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.laya-serve = {
      enable = true;
      package = laya.laya-serve;
      host = "127.0.0.1";
      inherit (cfg) port threads;
      device = "cpu";
    };
    homelab.hosting.laya.vhost.locations."/" = {
      proxyPass = "http://127.0.0.1:${toString cfg.port}/";
    };
  };
}
