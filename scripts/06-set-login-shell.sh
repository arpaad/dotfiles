#!/usr/bin/env bash
# Phase 1 · make zsh your login shell.  YOU run this (asks your password).
# After it finishes: close this terminal and open a NEW WSL window.
ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
