#!/usr/bin/env sh
set -e

FLAKE_DIR="$(dirname "$0")"
REMOTE=0

for arg in "$@"; do
    case "$arg" in
        --remote) REMOTE=1 ;;
    esac
done

if command -v nixos-rebuild >/dev/null; then
    BUILD_HOST_FLAG=""
    if [ "$REMOTE" = "1" ]; then
        BUILD_HOST_FLAG="--build-host root@groudon"
    fi
    nixos-rebuild switch --sudo --flake "$FLAKE_DIR" $BUILD_HOST_FLAG
elif command -v darwin-rebuild >/dev/null; then
    if [ "$REMOTE" = "1" ]; then
        echo "Error: --remote is not supported on darwin" >&2
        exit 1
    fi
    sudo darwin-rebuild switch --flake "$FLAKE_DIR"
else
    echo "Error: neither nixos-rebuild nor darwin-rebuild found in PATH" >&2
    exit 1
fi
