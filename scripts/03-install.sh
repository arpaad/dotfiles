#!/usr/bin/env bash
# Phase 3 · INSTALL the toolchain — mise, everything mise manages, Python, and
# the yazi plugins.
# Runs fine in bash: mise isn't on PATH yet (that happens in zsh, via .zshrc),
# so we call it by its full path.

MISE="$HOME/.local/bin/mise"
PYTHON_VERSION="3.14"

echo
echo "==> [1/4] mise itself -> $MISE"
curl https://mise.run | sh

echo
echo "==> [2/4] runtimes + CLI toolkit, as declared in mise/.config/mise/config.toml"
"$MISE" install

echo
echo "==> [3/4] default python $PYTHON_VERSION via uv"
# --default makes this the `python`/`python3` in ~/.local/bin. System python3 stays 3.12.
"$MISE" exec -- uv python install --default "$PYTHON_VERSION"

echo
echo "==> [4/4] yazi plugins, as pinned in yazi/.config/yazi/package.toml"
# Fetches piper.yazi, which renders markdown in yazi's preview pane via glow.
# Needs 02-setup.sh to have stowed the yazi package first.
"$MISE" exec -- ya pkg install

echo
echo "==> install done.  Now close this terminal and open a new one to land in zsh,"
echo "    then run 'nvim' once to let LazyVim install its plugins."
