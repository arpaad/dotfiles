#!/usr/bin/env bash
# Phase 1 · replace oh-my-zsh's default .zshrc with ours, move the old
# .gitconfig aside (its content is already merged into git/.gitconfig),
# then symlink our configs into ~ with stow.
DOTFILES="$HOME/.dotfiles"
rm "$HOME/.zshrc"
mv "$HOME/.gitconfig" "$HOME/.gitconfig.pre-rebuild"
stow -d "$DOTFILES" -t "$HOME" zsh
stow -d "$DOTFILES" -t "$HOME" starship
stow -d "$DOTFILES" -t "$HOME" git
