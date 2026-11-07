#!/usr/bin/env sh
set -e

FLAKE_DIR="$(dirname "$0")"
REMOTE=0
BUILD_ONLY=0

for arg in "$@"; do
    case "$arg" in
    --remote) REMOTE=1 ;;
    --build-only) BUILD_ONLY=1 ;;
    esac
done

if [ "$REMOTE" = "1" ]; then
    echo "Error: --remote is no longer supported (its build host, groudon, was retired)" >&2
    exit 1
fi

if command -v nixos-rebuild >/dev/null; then
    if [ "$BUILD_ONLY" = "1" ]; then
        nh os build .
    else
        nh os switch .
    fi
elif command -v darwin-rebuild >/dev/null; then
    if [ "$BUILD_ONLY" = "1" ]; then
        nh darwin build .
    else
        nh darwin switch .
    fi
else
    echo "Error: neither nixos-rebuild nor darwin-rebuild found in PATH" >&2
    exit 1
fi
