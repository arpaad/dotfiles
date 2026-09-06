#!/usr/bin/env bash
# Phase 4 · THEME — put one palette into every tool.
#
# Two kinds of work happen here:
#   · COPY   — tokyonight.nvim ships themes for other tools in its own extras/
#              directory, authored by the theme's maintainer. We copy those in
#              rather than hand-translating colours.
#   · RENDER — eza has no upstream theme with the semantics we want, so its
#              theme is generated from a template plus the ROLE_* block.
#
# Re-run this any time you change palette.env, or after updating tokyonight.
# It writes into the repo; run scripts/02-setup.sh afterwards if a package is new.

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
PALETTE="$DOTFILES/theme/.config/theme/palette.env"
TOKYONIGHT="$HOME/.local/share/nvim/lazy/tokyonight.nvim"

# `set -a` exports everything, which is what envsubst needs.
set -a
. "$PALETTE"
set +a

STYLE="tokyonight_${THEME_TOKYONIGHT_STYLE}"
EXTRAS="$TOKYONIGHT/extras"

echo
echo "==> theme: $THEME_NAME   (extras style: $STYLE)"

echo
echo "==> [1/4] eza — rendering theme.yml from the ROLE_* block"
envsubst < "$DOTFILES/scripts/templates/eza-theme.yml.in" > "$DOTFILES/eza/.config/eza/theme.yml"
# An undefined ROLE_ would silently become an empty colour, so fail loudly.
grep -n 'foreground: ""' "$DOTFILES/eza/.config/eza/theme.yml" && {
  echo "!!! a ROLE_ used by the template is not defined in palette.env"; exit 1; }
echo "    eza/.config/eza/theme.yml"

echo
echo "==> [2/4] checking tokyonight extras are present"
test -d "$EXTRAS" || {
  echo "!!! $EXTRAS not found — run nvim once so lazy.nvim installs tokyonight"; exit 1; }
echo "    $EXTRAS"

echo
echo "==> [3/4] copying the extras each tool wants"
cp "$EXTRAS/sublime/$STYLE.tmTheme" "$DOTFILES/bat/.config/bat/themes/$STYLE.tmTheme"
echo "    bat      -> bat/.config/bat/themes/$STYLE.tmTheme"
cp "$EXTRAS/yazi/$STYLE.toml" "$DOTFILES/yazi/.config/yazi/theme.toml"
# The upstream extra still uses yazi's pre-25 filetype schema, where rules were
# keyed by `name`. yazi 25 renamed that to `url` and now refuses to start on the
# old spelling ("at least one of `url` or `mime` must be specified"), so migrate.
sed -i 's/{ name = /{ url = /g' "$DOTFILES/yazi/.config/yazi/theme.toml"
echo "    yazi     -> yazi/.config/yazi/theme.toml  (name= -> url= migrated)"
cp "$EXTRAS/fzf/$STYLE.sh" "$DOTFILES/theme/.config/theme/fzf.sh"
echo "    fzf      -> theme/.config/theme/fzf.sh          (sourced by .zshrc)"
cp "$EXTRAS/delta/$STYLE.gitconfig" "$DOTFILES/theme/.config/theme/delta.gitconfig"
echo "    delta    -> theme/.config/theme/delta.gitconfig (included by .gitconfig)"
cp "$EXTRAS/tmux/$STYLE.tmux" "$DOTFILES/theme/.config/theme/tmux-theme.conf"
echo "    tmux     -> theme/.config/theme/tmux-theme.conf  (sourced by tmux.conf)"
cp "$EXTRAS/lazygit/$STYLE.yml" "$DOTFILES/lazygit/.config/lazygit/config.yml"
echo "    lazygit  -> lazygit/.config/lazygit/config.yml"

echo
echo "==> [4/4] rebuilding bat's theme cache (bat only reads themes from its cache)"
"$(command -v bat)" cache --build

echo
echo "==> theme done.  Neovim uses $THEME_NVIM directly — no generated file."
echo "    New package? run scripts/02-setup.sh.  Then open a new terminal."
