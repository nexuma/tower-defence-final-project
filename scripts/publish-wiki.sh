#!/usr/bin/env bash
#
# Regenerates the wiki pages from docs/ and pushes them to the GitHub wiki.
# Usage: make publish-wiki [COMMIT_MESSAGE="..."]
#
# The wiki clone is a publishing target only. Every page in it is overwritten
# from docs/, so local edits in the clone are refused rather than lost.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIKI_REPO="${WIKI_REPO:-"$REPO_ROOT/../tower-defence-final-project.wiki"}"
WIKI_DIR="$REPO_ROOT/build/wiki"
COMMIT_MESSAGE="${1:-}"

if [[ ! -d "$WIKI_REPO/.git" ]]; then
    echo "Wiki clone not found at: $WIKI_REPO"
    read -r -p "Clone it now? [Y/n] " clone_choice
    if [[ "$clone_choice" =~ ^[Nn]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
    git clone "https://github.com/nexuma/tower-defence-final-project.wiki.git" "$WIKI_REPO"
fi

if [[ -n "$(git -C "$WIKI_REPO" status --porcelain)" ]]; then
    echo "Stopped: the wiki clone has local edits that publishing would overwrite:"
    git -C "$WIKI_REPO" status --short
    echo
    echo "Wiki pages are generated from docs/. Copy your changes into the source"
    echo "file in docs/, then discard the edits in the clone with:"
    echo "  git -C \"$WIKI_REPO\" checkout -- ."
    exit 1
fi

git -C "$WIKI_REPO" pull --ff-only
make -C "$REPO_ROOT" wiki
cp "$WIKI_DIR"/*.md "$WIKI_REPO/"

if [[ -z "$(git -C "$WIKI_REPO" status --porcelain)" ]]; then
    echo "Wiki is already up to date."
    exit 0
fi

if [[ -z "$COMMIT_MESSAGE" ]]; then
    read -r -p "Wiki commit message: " COMMIT_MESSAGE
fi

if [[ -z "$COMMIT_MESSAGE" ]]; then
    echo "A commit message is required."
    exit 1
fi

git -C "$WIKI_REPO" add -- '*.md'
git -C "$WIKI_REPO" commit -m "$COMMIT_MESSAGE"
git -C "$WIKI_REPO" push origin master

echo "Wiki published successfully."
