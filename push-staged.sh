#!/usr/bin/env bash

# push-staged.sh - Sync staged git changes to remote NixOS/nix-darwin hosts
#
# Motivation:
# When managing multiple NixOS/nix-darwin systems, it's useful to test configuration
# changes on remote hosts before committing them locally. This script allows you to
# push staged git changes as patches to remote hosts without making a commit first.
# This enables rapid iteration and testing of nix-config changes across multiple
# systems while maintaining proper git workflow hygiene.
#
# The script ensures both local and remote repositories are synchronized with origin,
# creates a patch from staged changes, and applies it to specified remote hosts.
# This workflow prevents configuration drift and allows for safe testing of changes
# before permanent commits.

set -e

DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
    --dry-run)
        DRY_RUN=true
        shift
        ;;
    -*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        break
        ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "Usage: $0 [--dry-run] <hostname1> [hostname2] [hostname3] ..."
    echo "Example: $0 onix altaria trubbish"
    echo "         $0 --dry-run onix altaria"
    exit 1
fi

HOSTS=("$@")
REMOTE_DIR="/home/claby2/nix-config"
PATCH_FILE=$(mktemp /tmp/nix-config-patch.XXXXXX)

cleanup() {
    rm -f "$PATCH_FILE"
}
trap cleanup EXIT

echo "Checking local repository status..."
if ! git diff --cached --quiet; then
    echo "✓ Found staged changes"
else
    echo "✗ No staged changes found"
    exit 1
fi

if ! git diff --quiet; then
    echo "⚠ Warning: You have unstaged changes that won't be synced"
fi

echo "Checking if local repo is up-to-date with origin..."
git fetch --quiet
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "✗ Local repository is not up-to-date with origin"
    echo "Please pull latest changes first: git pull"
    exit 1
fi
echo "✓ Local repository is up-to-date"

echo "Creating patch file from staged changes..."
git diff --cached >"$PATCH_FILE"
if [ ! -s "$PATCH_FILE" ]; then
    echo "✗ Failed to create patch file"
    exit 1
fi
echo "✓ Created patch file: $PATCH_FILE"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "=== DRY RUN MODE - PATCH CONTENTS ==="
    cat "$PATCH_FILE"
    echo "=== END PATCH CONTENTS ==="
fi

for host in "${HOSTS[@]}"; do
    echo ""
    echo "Processing host: $host"

    echo "  Checking if remote repo is up-to-date..."
    REMOTE_HEAD=$(ssh "$host" "cd $REMOTE_DIR && git rev-parse HEAD" 2>/dev/null || echo "")
    if [ -z "$REMOTE_HEAD" ]; then
        echo "  ✗ Failed to check remote repository on $host"
        echo "  Make sure $REMOTE_DIR exists and is a git repository"
        continue
    fi

    if [ "$LOCAL" != "$REMOTE_HEAD" ]; then
        echo "  ✗ Remote repository on $host is not up-to-date"
        echo "  Remote HEAD: $REMOTE_HEAD"
        echo "  Local HEAD:  $LOCAL"
        echo "  Please ensure remote repo is synced first"
        continue
    fi
    echo "  ✓ Remote repository is up-to-date"

    echo "  Checking for uncommitted changes on remote..."
    if ! ssh "$host" "cd $REMOTE_DIR && git diff --quiet && git diff --cached --quiet" 2>/dev/null; then
        echo "  ✗ Remote repository has uncommitted changes"
        echo "  Please clean up remote repository first"
        continue
    fi
    echo "  ✓ Remote repository is clean"

    if [ "$DRY_RUN" = true ]; then
        echo "  ✓ All checks passed - would transfer and apply patch"
    else
        echo "  Transferring patch file..."
        if ! scp "$PATCH_FILE" "$host:/tmp/"; then
            echo "  ✗ Failed to transfer patch file to $host"
            continue
        fi
        echo "  ✓ Patch file transferred"

        echo "  Applying patch..."
        REMOTE_PATCH="/tmp/$(basename "$PATCH_FILE")"
        if ssh "$host" "cd $REMOTE_DIR && git apply '$REMOTE_PATCH' && rm '$REMOTE_PATCH'"; then
            echo "  ✓ Patch applied successfully on $host"
        else
            echo "  ✗ Failed to apply patch on $host"
            ssh "$host" "rm -f '$REMOTE_PATCH'" 2>/dev/null || true
        fi
    fi
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "Dry run completed!"
else
    echo "Sync completed!"
fi

