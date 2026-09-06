#!/usr/bin/env bash
# Phase 1 · install mise, link its config, download the CLI toolkit.
DOTFILES="$HOME/.dotfiles"
MISE="$HOME/.local/bin/mise"
curl https://mise.run | sh
stow -d "$DOTFILES" -t "$HOME" mise
"$MISE" install
