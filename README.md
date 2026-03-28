# nix-config

My nix-config (NixOS + nix-darwin).

This configuration assumes this repository is cloned into `~/nix-config`.

## Directory Structure

```
├── flake.nix              # Main flake configuration
├── hosts/                 # Per-host system configurations
│   ├── onix/
│   ├── altaria/
│   ├── groudon/
│   └── applin/
├── hostclass/             # Hostclass definitions
├── modules/
│   ├── hostclass.nix      # Hostclass option definition
│   ├── home/              # User-specific home-manager config
│   └── homelab/           # Self-hosted services
├── apps/                  # Application dotfiles
├── meta/                  # Shared metadata
├── rebuild.sh             # Rebuild helper script
└── secrets.nix            # Agenix secrets configuration
```

## Hostclass System

Each host imports a hostclass file from the top-level [`hostclass/`](./hostclass)
directory. Hostclasses inherit from one another via `imports`, with
[`base`](./hostclass/base.nix) as the root. The current hostclasses are:

- **`base`** - Common configuration shared by all hosts
- **`server`** - NixOS servers (imports `base`)
- **`mac`** - macOS/nix-darwin machines (imports `base`)

A system managed via this configuration will have `$HOSTCLASS` defined.

### Configuration Pattern

Each host imports its hostclass directly, passing an optional `motd` parameter:

```nix
# Example host configuration
{
  imports = [
    (import ../../hostclass/server.nix { motd = builtins.readFile ./hostname; })
  ];
  # Additional host-specific configuration...
}
```

## Secrets Management

Secrets are managed using [agenix](https://github.com/ryantm/agenix) for age-encrypted secrets:

- Encrypted secrets stored in `hosts/<name>/secrets/`
- Secrets configuration defined in [`secrets.nix`](./secrets.nix)
- Age keys managed through SSH keys in [`meta/default.nix`](./meta/default.nix)

## Development

### Adding a New Host

1. Create host directory: `hosts/<hostname>/`
2. Define host configuration in `hosts/<hostname>/default.nix`
3. Add hardware configuration: `hosts/<hostname>/hardware.nix`
4. Register in `flake.nix` using `mkNixosHost` or `mkDarwinHost`
5. Configure appropriate hostclass

### Adding Homelab Services

For homelab services, add a module to
[`modules/homelab/`](./modules/homelab/), following [NixOS
Modules](https://nixos.wiki/wiki/NixOS_modules) convention.

Make sure to import the module in [`modules/homelab/default.nix`](./modules/homelab/default.nix).

### Managing Secrets

1. Define secret in `secrets.nix`
2. Encrypt using `agenix -e <secret-name>.age`
