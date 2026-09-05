#!/usr/bin/env bash
# Phase 1 · core system packages needed to run everything else and to
# build native code. YOU run this (it uses sudo / your password).
PACKAGES="ca-certificates software-properties-common curl unzip git build-essential stow zsh"
sudo apt update
sudo apt install -y $PACKAGES
