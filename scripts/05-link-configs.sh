#!/usr/bin/env bash
# Phase 1 · replace the default configs oh-my-zsh and git may have left in ~,
# then symlink ours into place with stow.  -f so a fresh machine (where these
# files don't exist yet) behaves the same as one that already had them.
DOTFILES="$HOME/.dotfiles"
rm -f "$HOME/.zshrc"
rm -f "$HOME/.gitconfig"
stow -d "$DOTFILES" -t "$HOME" zsh
stow -d "$DOTFILES" -t "$HOME" starship
stow -d "$DOTFILES" -t "$HOME" git
