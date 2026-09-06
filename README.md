# dotfiles — a catalog

A terminal-centric dev environment: zsh + starship, mise-managed toolchains, tmux, and
Neovim/LazyVim. Built for **WSL Ubuntu 24.04**.

This README is a **catalog** — every piece, what it does, how it got installed, and
whether you can take it on its own. Want the whole thing on a fresh machine instead?
→ **[INSTALL.md](INSTALL.md)**.

Everything here falls into one of three buckets:

| | Bucket | What it means |
|---|---|---|
| **1** | [Installed by hand](#1--installed-by-hand) | System-level things a script or you install once. Not portable — tied to the OS. |
| **2** | [Config files](#2--config-files) | Plain text, symlinked into `~` with stow. **Copy any of these anywhere.** |
| **3** | [The mise toolset](#3--the-mise-toolset) | One TOML file lists ~15 CLI tools; `mise install` fetches them all. |

No binaries are committed. The repo is a recipe that re-fetches them.

---

## 1 · Installed by hand

These touch the machine itself, so they can't just be copied — each row says what
installs it. Take any row on its own; they don't depend on each other except where noted.

| Item | What it's for | How it's installed | Notes |
|---|---|---|---|
| **Nerd Font** (Hack) | glyphs for the prompt and file icons | manually, on the **host OS** — not in WSL | the only truly by-hand step; without it you get □ boxes |
| **apt base packages** | `git`, `build-essential`, `stow`, `curl`, `unzip`, `zsh`, `ca-certificates`, `software-properties-common` | `scripts/01-prepare.sh`, step 1 (sudo) | `stow` is what links bucket 2; `build-essential` is needed by tools that compile |
| **git from PPA** | Ubuntu 24.04 ships git 2.43; the PPA gives 2.5x | `scripts/01-prepare.sh`, step 2 (sudo) | drop this if 2.43 is fine for you |
| **podman** | rootless containers | `scripts/01-prepare.sh`, step 2 (sudo) | independent of everything else here |
| **mise** | version manager — installs bucket 3 | `curl https://mise.run \| sh`, in `scripts/03-install.sh` | lands in `~/.local/bin/mise` |
| **oh-my-zsh** | zsh framework: completions, git aliases | `scripts/01-prepare.sh`, step 3 | required by `zsh/.zshrc` as written |
| **zsh plugins** ×3 | `zsh-completions`, `zsh-autosuggestions`, `zsh-syntax-highlighting` | git-cloned into `~/.oh-my-zsh/custom/plugins` by `scripts/01-prepare.sh`, step 3 | each is optional — comment its line out of the `plugins=()` array |
| **zsh as login shell** | so a new terminal starts in zsh | `scripts/01-prepare.sh`, step 4 → `chsh` | needs a *new login* to take effect; undo with `chsh -s /usr/bin/bash` |
| **Python 3.14** | the default `python` / `python3` | `uv python install --default 3.14`, in `scripts/03-install.sh` | uv owns the interpreters. The system `python3` (3.12) is never touched — the OS depends on it |
| **LazyVim plugins** | Neovim's actual plugin set | installs itself the first time you run `nvim` | pinned by `nvim/.config/nvim/lazy-lock.json` |
| **LSP servers** | language servers for Neovim | Mason installs them on demand, per language | nothing to configure up front |

---

## 2 · Config files

Plain text, all of it portable. Each top-level directory is a **stow package** that
mirrors the paths it owns under `~` — so `stow zsh` creates `~/.zshrc` as a symlink to
`zsh/.zshrc` and nothing else.

**Taking just one:** either `cd ~/.dotfiles && stow <package>` for a symlink, or just
copy the file to the path in the *Lands at* column. They're ordinary files — no
templating, no build step. The *Needs* column is what has to exist for it to work.

| Package | Lands at | What it configures | Needs |
|---|---|---|---|
| `zsh/` | `~/.zshrc` | plugin list, `PATH`, aliases, and the `eval` lines that activate mise / starship / zoxide / fzf | oh-my-zsh + the 3 plugins; the tools it evals (comment out the lines for any you skip) |
| `starship/` | `~/.config/starship.toml` | the prompt — blank line between prompts, timing on commands over 2s | `starship`, a Nerd Font |
| `git/` | `~/.gitconfig` | identity, delta as pager and diff filter, `zdiff3` conflicts, `colorMoved` | `delta` (drop the `[core] pager` + `[delta]` blocks to go without) · **edit `[user]` to your own name/email** |
| `tmux/` | `~/.config/tmux/tmux.conf` | `Ctrl-a` prefix, mouse on, 1-based numbering, vi copy mode, 10k scrollback, splits that keep the cwd | `tmux`. Fully standalone otherwise |
| `nvim/` | `~/.config/nvim/` | a stock LazyVim starter + `lazy-lock.json` pinning plugin versions | `neovim`, `git`, a Nerd Font. Standalone |
| `mise/` | `~/.config/mise/config.toml` | the tool list — see bucket 3 | `mise` |

### What's actually in `zsh/.zshrc`

```zsh
alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'
alias cat='bat'
# cd  -> smart cd (zoxide), learns the dirs you visit
# cdi -> interactive fuzzy dir jump (zoxide + fzf)
# Ctrl-R history search, Ctrl-T file picker (fzf)
```

Aliases are interactive-only, so `#!/bin/bash` scripts are unaffected. Escape hatch:
`\ls`, `command cat`.

### tmux bindings worth knowing

Prefix is `Ctrl-a` (tutorials say `Ctrl-b` — press `Ctrl-a` where they do).

| Keys | Does |
|---|---|
| `prefix v` or `prefix \|` | split side-by-side, same directory |
| `prefix s` or `prefix -` | split top/bottom, same directory |
| `prefix h/j/k/l` | move between panes |
| `prefix r` | reload the config |

---

## 3 · The mise toolset

One file — `mise/.config/mise/config.toml` — declares everything below. `mise install`
fetches the lot into `~/.local/share/mise`, and `mise activate` (already in `.zshrc`)
puts them on `PATH`.

**Taking just some:** you don't need this repo. Install mise, then
`mise use -g fzf ripgrep fd bat` — or copy the lines you want into your own
`~/.config/mise/config.toml`.

**Runtimes**

| Tool | Version | For |
|---|---|---|
| `node` | 24 | JS/TS, and the npm-installed CLIs that come with it |
| `go` | 1.27 | Go toolchain; `$GOPATH/bin` is on `PATH` via `.zshrc` |
| `uv` | latest | Python package + interpreter manager (also installs Python itself) |

**Shell & editing**

| Tool | For |
|---|---|
| `starship` | the prompt |
| `neovim` | editor (config in bucket 2) |
| `tmux` | terminal multiplexer (config in bucket 2) |

**CLI toolkit** — modern replacements and daily drivers

| Tool | Replaces / does | Wired into |
|---|---|---|
| `fzf` | fuzzy finder | `Ctrl-R`, `Ctrl-T`, `cdi` |
| `ripgrep` (`rg`) | faster `grep` | |
| `fd` | friendlier `find` | |
| `bat` | `cat` with syntax highlighting | `alias cat='bat'` |
| `eza` | `ls` with git status and icons | `ls`/`ll`/`la`/`lt` aliases |
| `zoxide` | `cd` that learns your dirs | replaces `cd`; `cdi` for interactive |
| `delta` | readable git diffs | git pager + diff filter |
| `lazygit` | TUI for git | |
| `yazi` | TUI file manager | |
| `jq` | JSON on the command line | |
| `btop` | `top`, but good | |
| `tealdeer` (`tldr`) | short, example-first man pages | |

Tools come from mise rather than apt so they keep their real upstream names — `bat`,
`fd`, `rg`, not Debian's `batcat`/`fdfind`. That's why the alias is simply `cat='bat'`.

---

## Layout

```
~/.dotfiles/
├── README.md      this catalog
├── INSTALL.md     the run-in-order install
├── zsh/           .zshrc                     ─┐
├── starship/      .config/starship.toml       │
├── mise/          .config/mise/config.toml    ├─ bucket 2: stow packages
├── git/           .gitconfig                  │
├── tmux/          .config/tmux/tmux.conf      │
├── nvim/          .config/nvim/              ─┘
└── scripts/       01-prepare, 02-setup, 03-install   (not a stow package)
```

The repo lives directly in `~` because stow's default target is the *parent* of the stow
directory — so `cd ~/.dotfiles && stow zsh` needs no flags. (The scripts still pass
`-d`/`-t` explicitly so they work from any directory.)

## Changing things

| To… | Do this |
|---|---|
| add a CLI tool or runtime | add it to `mise/.config/mise/config.toml`, run `mise install` |
| add a system package | add it to `APT_BASE` or `APT_TOOLS` in `scripts/01-prepare.sh` |
| turn a zsh plugin off | comment its line in the `plugins=(...)` array in `zsh/.zshrc` |
| link a new package | add the directory, add its name to `PACKAGES` in `scripts/02-setup.sh`, then `cd ~/.dotfiles && stow <name>` |
| unlink one | `cd ~/.dotfiles && stow -D <name>` |
| reset the zoxide database | `rm ~/.local/share/zoxide/db.zo` |

## Conventions

- **Three scripts, three jobs.** `01-prepare` touches the system (apt, zsh), `02-setup`
  links this repo's configs into `~`, `03-install` fetches the mise toolchain. Nothing
  in 02 or 03 needs sudo.
- **Scripts are flat.** One command per line — no conditionals, loops, or functions —
  with an `==>` echo before each step. Readable top to bottom, and obvious where it
  stopped if one fails.
- **Config is text and goes in git. Binaries never do** — they're re-fetched from the
  recipe. Secrets (ssh keys, tokens) stay out of this repo entirely.
- **Edit files in this repo, never the symlinks in `~`.** Same file either way, but
  committing from here is what keeps the machine reproducible.
