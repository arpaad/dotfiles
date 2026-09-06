# How to customise your zsh

A terminal-centric development environment: **zsh + starship** for the shell,
a **modern CLI toolkit** managed by one file, **tmux** for panes and sessions,
and **Neovim/LazyVim** for editing — all sharing a single colour palette.

This repo is the configuration itself, but it is written to be **read rather
than installed**. Every tool has a page saying what it is for, why it was
chosen over the obvious alternative, and what each setting in its config
actually does.

> **Already have a zsh you like?** You do not need any of this. Take the parts
> you want — start with **[the catalog](docs/tools/README.md)**, or the
> [ten-line version](docs/install/README.md#trying-it-without-adopting-anything)
> that adds the toolkit to a `.zshrc` you already have.

Nothing here is distro-specific except the bootstrap. It is developed on WSL
Ubuntu, and works unchanged on Fedora, Arch or macOS — see
**[installing](docs/install/README.md)**.

---

## The toolset

The organising rule: **the familiar command keeps doing the familiar thing, and
a better tool takes over quietly underneath.**

| You type | You get | What changes |
|---|---|---|
| `ls` `ll` `la` `lt` | [eza](docs/tools/navigation.md#eza--ls-but-it-answers-more-questions) | git status per file, icons, and colours that tell you what is generated, what is a secret, and what is yours |
| `cd` | [zoxide](docs/tools/navigation.md#zoxide--cd-that-remembers) | remembers where you go — `cd dot` reaches `~/.dotfiles` from anywhere |
| `cat` | [bat](docs/tools/reading.md#bat--cat-with-syntax-highlighting) | syntax highlighting, line numbers, git markers |
| `md` | [glow](docs/tools/reading.md#glow--markdown-rendered) | markdown **rendered**, not source — a new word, because it is a new thing |
| `Ctrl-R` | [fzf](docs/tools/navigation.md#fzf--the-fuzzy-picker-everything-else-plugs-into) | fuzzy history search instead of scrolling |
| `git diff` | [delta](docs/tools/git.md#delta) | syntax-highlighted diffs with word-level detail |

Plus the tools that add rather than replace: `rg` (search), `fd` (find),
`jq` (JSON), `tldr` (examples), `btop` (processes), `lazygit`, `yazi`, `tmux`
and `nvim`.

**Colour is treated as information, not decoration.** A Go file is the same
colour in `ls`, in `cat`, in a diff and in the editor — because all of them
read one palette file. And in a listing, **bold** means you can act on it, dim
means you can ignore it, underline means something is unsafe. That single idea
is the highest-value thing in this repo:
**[what `ls` colours mean](docs/theme/eza-colours.md)**.

---

## Documentation

| | |
|---|---|
| **[The catalog](docs/tools/README.md)** | **start here** — every tool: what for, why this one, and every setting explained |
| ├ [Shell](docs/tools/shell.md) | zsh, oh-my-zsh and its four plugins, starship, every line of `.zshrc` |
| ├ [Navigation](docs/tools/navigation.md) | eza, zoxide, fzf, fd, yazi |
| ├ [Reading](docs/tools/reading.md) | bat, glow, ripgrep, jq, tldr, btop |
| ├ [Git](docs/tools/git.md) | the `.gitconfig` block by block, delta, lazygit |
| ├ [tmux](docs/tools/tmux.md) | panes and sessions, every line of `tmux.conf` |
| ├ [Neovim](docs/tools/neovim.md) | LazyVim, the LSP set, the review workflow |
| └ [Runtimes](docs/tools/runtimes.md) | mise, and why the toolchain is not installed from the distro |
| **[Theme](docs/theme/README.md)** | one palette driving nine tools, and how to change all of them at once |
| └ [What `ls` colours mean](docs/theme/eza-colours.md) | every colour, bold and underline in a listing, decoded |
| **[Tutorials](docs/tutorials/README.md)** | hands-on walkthroughs: [Neovim](docs/tutorials/neovim.md) · [tmux](docs/tutorials/tmux.md) · [yazi](docs/tutorials/yazi.md) · [markdown](docs/tutorials/markdown.md) |
| **[Installing](docs/install/README.md)** | what to install by hand · [Ubuntu/WSL](docs/install/ubuntu-wsl.md) · [Fedora & others](docs/install/fedora.md) |

---

## What you install by hand

Everything else is fetched by `mise install` from one config file. These seven
are the layer underneath it — *what* they are and *why*; the **how** is in
[installing](docs/install/README.md), which has the commands per distro.

| What | Why it's needed |
|---|---|
| **A Nerd Font** | the icons and prompt glyphs only exist in a patched font. Installed where your *terminal emulator* runs — on WSL, that is Windows |
| **Base build tools** — `curl`, `git`, `unzip`, a C toolchain | mise's installer needs curl; a few tools compile |
| **`stow`** | symlinks this repo's configs into `~`. Only if you adopt the repo |
| **`zsh`** | the shell everything assumes |
| **oh-my-zsh + 3 plugins** | `.zshrc` as written loads them → [Shell](docs/tools/shell.md) |
| **`mise`** | installs the entire rest of the toolchain. No sudo — it lives in `~/.local/bin` |
| **zsh as login shell** | `chsh`. Takes effect on the next *login*, not the next tab |

Optional and unrelated to the rest: a newer git than your distro ships, and
podman.

---

## Layout

```
~/.dotfiles/
├── README.md            this page
├── docs/
│   ├── tools/           the catalog — what each tool is for and why
│   ├── theme/           the palette, and the ls colour legend
│   ├── tutorials/       hands-on walkthroughs
│   └── install/         by-hand layer · ubuntu-wsl · fedora
├── zsh/          .zshrc                    ─┐
├── starship/     .config/starship.toml      │
├── mise/         .config/mise/config.toml   │
├── git/          .gitconfig                 │
├── tmux/         .config/tmux/tmux.conf     ├─ stow packages: each mirrors
├── nvim/         .config/nvim/              │  the paths it owns under ~
├── yazi/         .config/yazi/              │
├── eza/          .config/eza/theme.yml      │
├── bat/          .config/bat/themes/        │
├── lazygit/      .config/lazygit/           │
├── theme/        .config/theme/palette.env ─┘  ← the palette everything reads
└── scripts/      01-prepare · 02-setup · 03-install · 04-theme
```

Each top-level directory is a **stow package**: `stow zsh` creates `~/.zshrc`
as a symlink to `zsh/.zshrc`, and nothing else. So you can take exactly one
package, or just copy the file — they are ordinary text with no templating.

---

## Changing things

| To… | Do this |
|---|---|
| **re-theme everything at once** | edit `theme/.config/theme/palette.env`, run `scripts/04-theme.sh`, open a new shell → [Theme](docs/theme/README.md) |
| add a CLI tool or runtime | add it to `mise/.config/mise/config.toml`, run `mise install` |
| turn a zsh plugin off | comment its line in the `plugins=(...)` array in `zsh/.zshrc` |
| link a new package | add the directory, add its name to `PACKAGES` in `scripts/02-setup.sh`, then `stow <name>` |
| unlink one | `cd ~/.dotfiles && stow -D <name>` |
| add a yazi plugin | `ya pkg add <owner>/<repo>` — commit the pinned rev it records, not the plugin |
| remove all of it | [installing → removing](docs/install/README.md#removing-it) |

---

## Conventions

- **Four scripts, four jobs.** `01-prepare` touches the system (apt, zsh),
  `02-setup` links the configs into `~`, `03-install` fetches the toolchain,
  `04-theme` applies the palette. Only 01 needs sudo, and only 01 is
  distro-specific.
- **Scripts are flat.** One command per line — no conditionals, loops or
  functions — with an `==>` echo before each step. Readable top to bottom, and
  obvious where it stopped if one fails.
- **Config is text and goes in git. Binaries never do** — they are re-fetched
  from the recipe, at versions pinned in `mise/.config/mise/config.toml` and
  `nvim/.config/nvim/lazy-lock.json`. Secrets stay out entirely.
- **Everything is a feature flag.** Nothing here is load-bearing for anything
  else except where a page says so. Each catalog page states what breaks if you
  remove the thing — usually nothing.
- **Edit files in this repo, never the symlinks in `~`.** Same file either way,
  but committing from here is what keeps the machine reproducible.
