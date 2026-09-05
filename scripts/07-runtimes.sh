#!/usr/bin/env bash
# Phase 2 · runtimes are declared in mise/.config/mise/config.toml (node, go, uv).
# `mise install` installs anything not yet present; uv adds the Python interpreter.
# Run this in the NEW zsh shell.
PYTHON_VERSION="3.14"
mise install
# --default makes this the `python`/`python3` in ~/.local/bin (system python3 stays 3.12).
uv python install --default $PYTHON_VERSION
