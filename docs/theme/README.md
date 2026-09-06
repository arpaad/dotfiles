# One palette, nine tools

Everything that draws colour in this setup reads from a single file:
**`theme/.config/theme/palette.env`** → `~/.config/theme/palette.env`.

Current theme: **Tokyo Night Moon**.

---

## Why this theme

Not because of how it looks — because of where it comes from.

`tokyonight.nvim` is LazyVim's default colorscheme, and upstream ships
**hand-authored themes for other tools** inside its own `extras/` directory: bat,
yazi, fzf, delta, tmux, lazygit, btop and more. So each tool is themed by the
theme's own maintainer from the canonical palette, rather than by me eyeballing
approximate equivalents per tool.

That is the part that makes "everything matches" true rather than roughly true.
Catppuccin has comparable coverage and is the obvious alternative; Nord and
Solarized are poor fits here for a specific reason — the `ls` scheme needs about
thirteen *distinguishable* hues, and muted palettes collapse several of them.

---

## Who reads what

| Tool | How it is themed | Source |
|---|---|---|
| **Neovim** | reads `THEME_NVIM` from `palette.env` directly | `lua/plugins/colorscheme.lua` |
| **bat** | `$BAT_THEME` ← `THEME_BAT` | `.tmTheme` copied into `bat/.config/bat/themes/` |
| **delta** | follows `$BAT_THEME` for syntax, plus generated diff styles | `~/.config/theme/delta.gitconfig`, included by `.gitconfig` |
| **fzf** | appends to `$FZF_DEFAULT_OPTS` | `~/.config/theme/fzf.sh`, sourced by `.zshrc` |
| **yazi** | `theme.toml` | copied to `yazi/.config/yazi/theme.toml` |
| **tmux** | status bar | `~/.config/theme/tmux-theme.conf`, sourced by `tmux.conf` |
| **lazygit** | `config.yml` | copied to `lazygit/.config/lazygit/config.yml` |
| **eza** | **generated** from a template + the `ROLE_*` block | `scripts/templates/eza-theme.yml.in` |
| **glow** | follows the terminal's light/dark mode (`-s auto`) | nothing to configure |

Only eza is *generated* rather than copied, because no upstream eza theme carries
the semantics described in **[the eza colour legend](eza-colours.md)** — hue for role, bold
for actionable, dim for ignorable, underline for unsafe.

`starship` and `btop` are deliberately left alone: starship here is intentionally
near-colourless, and btop rewrites its own config file on exit, so a stow symlink
would fight it.

---

## The two layers in `palette.env`

This is the part worth understanding, because it is what makes a re-theme cheap.

```
C_*     the palette      C_ORANGE="#ff966c"      ← what colours exist
  ↓
ROLE_*  the meaning      ROLE_CONFIG="$C_ORANGE" ← what colours mean
```

`ls` never asks for orange. It asks for `ROLE_CONFIG`. So repointing the palette
changes how everything looks while every *meaning* survives intact — config files
stay visually distinct from data files without anyone re-deciding which hue that
should be.

This was tested rather than assumed: the eza scheme has 25 assertions covering
what colour and attributes each kind of file gets. Switching the palette from
Catppuccin Frappé to Tokyo Night Moon changed every colour and kept all 25
passing, with no edit to the eza theme itself.

---

## Changing the theme

### A different variant of the same theme

One word — `THEME_TOKYONIGHT_STYLE` picks which `extras/` files get copied
(`moon`, `night`, `storm`, `day`):

```bash
# in theme/.config/theme/palette.env
THEME_NVIM="tokyonight-night"
THEME_TOKYONIGHT_STYLE="night"
THEME_BAT="tokyonight_night"
```

```bash
scripts/04-theme.sh      # re-copy and re-render
```

Then open a new terminal. Repoint the `C_*` block too if you want eza to follow —
it does not read the extras.

### A completely different theme

1. Set `THEME_NVIM` to any colorscheme LazyVim can load. It bundles **tokyonight**
   and **catppuccin** with full integrations, so those two need no plugin; for
   anything else add a spec to `lua/plugins/colorscheme.lua`.
2. If that theme also ships `extras/` (Catppuccin does, via its own repos), point
   the copy steps in `scripts/04-theme.sh` at them. Otherwise set `THEME_BAT` to a
   name from `bat --list-themes` and drop a `theme.toml` in for yazi.
3. Repoint the `C_*` palette. Leave `ROLE_*` alone unless you actually want to
   change what a colour *means*.
4. `scripts/04-theme.sh`, then a new terminal.

---

## What the script does

`scripts/04-theme.sh` is re-runnable and idempotent — running it twice produces
byte-identical files.

```
[1/4]  render eza/.config/eza/theme.yml   from template + ROLE_*
[2/4]  check tokyonight's extras/ exists  (needs nvim to have installed it)
[3/4]  copy the extras each tool wants    bat, yazi, fzf, delta, tmux, lazygit
[4/4]  bat cache --build                  bat only reads themes from its cache
```

Two guards in there worth knowing about, because both were real failures:

- **An undefined `ROLE_` would render as an empty colour**, which eza accepts
  silently. The script greps for `foreground: ""` and fails loudly instead.
- **The upstream yazi extra uses yazi's pre-25 schema** (`name =`, since renamed
  to `url =`). yazi 26 refuses to start on the old spelling, so the script
  migrates it with a `sed` after copying.

Also note: **bat ignores a theme file until you rebuild its cache**, and it names
custom themes after the *filename*, not the `<name>` inside the `.tmTheme` — this
theme's file declares `TokyoNight` but bat only answers to `tokyonight_moon`.

---

## Files

```
theme/.config/theme/
├── palette.env          ← the source of truth. hand-written.
├── fzf.sh               ← generated (copied)
├── delta.gitconfig      ← generated (copied)
└── tmux-theme.conf      ← generated (copied)

scripts/
├── 04-theme.sh          ← the generator
└── templates/
    └── eza-theme.yml.in ← eza's structure; colours are ROLE_ placeholders

bat/.config/bat/themes/tokyonight_moon.tmTheme   ← generated (copied)
yazi/.config/yazi/theme.toml                     ← generated (copied + migrated)
lazygit/.config/lazygit/config.yml               ← generated (copied)
eza/.config/eza/theme.yml                        ← generated (rendered)
nvim/.config/nvim/lua/plugins/colorscheme.lua    ← reads palette.env
```

Only `palette.env` and the template are meant to be edited by hand. Everything
else is reproduced by `scripts/04-theme.sh`.
