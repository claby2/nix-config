# nix-config

My nix-config (NixOS + nix-darwin).

This configuration assumes this repository is cloned into `~/nix-config`.

## Directory Structure

```
├── flake.nix              # Main flake configuration
├── hosts/                 # Per-host system configurations
│   ├── onix/
│   ├── altaria/
│   ├── trubbish/
│   └── applin/
├── modules/
│   ├── common/
│   │   ├── hostclass/
│   │   └── home/          # User-specific home-manager config
│   ├── nixos/
│   │   ├── hostclass/
│   │   └── homelab/       # Self-hosted services
│   └── darwin/
│       └── hostclass/
├── apps/                  # Application dotfiles
├── meta/                  # Shared metadata
└── secrets.nix            # Agenix secrets configuration
```

## Hostclass System

The configuration uses a layered hostclass inheritance system to promote
modularity and code reuse. Hostclasses can define properties and inherit
properties from one another, forming a directed acyclic graph. The graph should
have a single root hostclass: [`base`](./modules/common/hostclass/base.nix).

A system managed via this configuration will have `$HOSTCLASS` defined.

### Configuration Pattern

Each host enables its hostclass via `hostclass.<type>.enable = true`.

```nix
# Example host configuration
{
  hostclass.server.enable = true;  # Automatically enables base
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
[`modules/nixos/homelab/`](./modules/nixos/homelab/), following [NixOS
Modules](https://nixos.wiki/wiki/NixOS_modules) convention.

Make sure to import the module in [`modules/nixos/homelab/default.nix`](./modules/nixos/homelab/default.nix).

### Managing Secrets

1. Define secret in `secrets.nix`
2. Encrypt using `agenix -e <secret-name>.age`
