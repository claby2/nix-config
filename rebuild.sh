#!/usr/bin/env sh
set -e

FLAKE_DIR="$(dirname "$0")"

if command -v nixos-rebuild >/dev/null; then
    sudo nixos-rebuild switch --flake "$FLAKE_DIR"
elif command -v darwin-rebuild >/dev/null; then
    sudo darwin-rebuild switch --flake "$FLAKE_DIR"
else
    echo "Error: neither nixos-rebuild nor darwin-rebuild found in PATH" >&2
    exit 1
fi
