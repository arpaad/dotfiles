#!/usr/bin/env bash
# Phase 2 · SETUP the configs — symlink every package in this repo into ~ with stow.
# No downloads, no sudo. Every file it creates in ~ is a symlink back into ~/.dotfiles.

DOTFILES="$HOME/.dotfiles"
PACKAGES="mise zsh starship git tmux nvim yazi eza theme bat lazygit"

echo
echo "==> [1/2] clear the defaults oh-my-zsh and git left behind"
# -f so a fresh machine (where these don't exist yet) behaves like one that had them.
rm -f "$HOME/.zshrc"
rm -f "$HOME/.gitconfig"

echo
echo "==> [2/2] stow: $PACKAGES"
stow -d "$DOTFILES" -t "$HOME" $PACKAGES

echo
echo "==> setup done.  Next:  scripts/03-install.sh"
