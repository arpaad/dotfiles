#!/usr/bin/env bash
# Phase 3 · INSTALL the toolchain — mise, everything mise manages, and Python.
# Runs fine in bash: mise isn't on PATH yet (that happens in zsh, via .zshrc),
# so we call it by its full path.

MISE="$HOME/.local/bin/mise"
PYTHON_VERSION="3.14"

echo
echo "==> [1/3] mise itself -> $MISE"
curl https://mise.run | sh

echo
echo "==> [2/3] runtimes + CLI toolkit, as declared in mise/.config/mise/config.toml"
"$MISE" install

echo
echo "==> [3/3] default python $PYTHON_VERSION via uv"
# --default makes this the `python`/`python3` in ~/.local/bin. System python3 stays 3.12.
"$MISE" exec -- uv python install --default "$PYTHON_VERSION"

echo
echo "==> install done.  Now close this terminal and open a new one to land in zsh,"
echo "    then run 'nvim' once to let LazyVim install its plugins."
