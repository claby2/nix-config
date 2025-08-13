#!/bin/bash

# check-sync.sh - Verify nix-config repository synchronization across hosts
#
# Motivation:
# When managing multiple NixOS/nix-darwin systems with a shared configuration
# repository, it's critical to ensure all hosts are in sync. This script provides
# a comprehensive overview of the git status across all managed hosts, helping
# to identify configuration drift, uncommitted changes, or synchronization issues.
#
# The script checks for unstaged changes, staged changes, untracked files, and
# origin synchronization status on both the local repository and all specified
# remote hosts. This visibility is essential for maintaining consistent system
# configurations and avoiding deployment surprises when rebuilding systems.

set -e

VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
    -v | --verbose)
        VERBOSE=true
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
    echo "Usage: $0 [-v|--verbose] <hostname1> [hostname2] [hostname3] ..."
    echo "Example: $0 onix altaria trubbish"
    echo ""
    echo "Checks if all hosts have synchronized nix-config repositories."
    exit 1
fi

HOSTS=("$@")
REMOTE_DIR="/home/claby2/nix-config"
SYNC_ISSUES=0

check_git_status() {
    local location="$1"
    local ssh_prefix="$2"

    local head branch
    head=$($ssh_prefix git rev-parse HEAD 2>/dev/null || echo "ERROR")
    if [ "$head" = "ERROR" ]; then
        echo "✗  Cannot access repository"
        return 1
    fi

    branch=$($ssh_prefix git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "Branch: $branch"
    echo "Commit: $head"

    if [ -z "$ssh_prefix" ]; then
        $ssh_prefix git fetch --quiet 2>/dev/null || true
        local remote_head
        remote_head=$($ssh_prefix git rev-parse @{u} 2>/dev/null || echo "")
        if [ -n "$remote_head" ] && [ "$head" != "$remote_head" ]; then
            echo "⚠  Not up-to-date with origin"
            [ "$VERBOSE" = true ] && echo "   Local: $head" && echo "   Remote: $remote_head"
        else
            echo "✓  Up-to-date with origin"
        fi
    fi

    if ! $ssh_prefix git diff --quiet 2>/dev/null; then
        echo "⚠  Has unstaged changes"
        if [ "$VERBOSE" = true ]; then
            echo "   Unstaged files:"
            $ssh_prefix git diff --name-only | sed 's/^/     /'
        fi
    else
        echo "✓  No unstaged changes"
    fi

    if ! $ssh_prefix git diff --cached --quiet 2>/dev/null; then
        echo "⚠  Has staged changes"
        if [ "$VERBOSE" = true ]; then
            echo "   Staged files:"
            $ssh_prefix git diff --cached --name-only | sed 's/^/     /'
        fi
    else
        echo "✓  No staged changes"
    fi

    local untracked
    untracked=$($ssh_prefix git ls-files --others --exclude-standard 2>/dev/null || echo "")
    if [ -n "$untracked" ]; then
        echo "⚠  Has untracked files"
        if [ "$VERBOSE" = true ]; then
            echo "   Untracked files:"
            echo "$untracked" | sed 's/^/     /'
        fi
    else
        echo "✓  No untracked files"
    fi
}

echo "=== Repository Sync Check ==="
echo ""

echo "Local repository:"
echo "=================="
check_git_status "local" ""
echo ""

for host in "${HOSTS[@]}"; do
    echo "Host: $host"
    echo "===================="

    check_git_status "$host" "ssh $host cd $REMOTE_DIR &&"
done
