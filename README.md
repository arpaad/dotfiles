# dotfiles

Reproducible, terminal-centric dev environment for **WSL Ubuntu 24.04** (portable to any Linux).
Config lives here as real files, symlinked into `~` with GNU stow.
Binaries are never stored — they're a *recipe*: `mise/.config/mise/config.toml` (dev tools) + `scripts/` (system packages).

Every script is **flat**: one command per line, no conditionals / loops / functions — read top to bottom.

## Reproducibility model

A system splits into two kinds of thing, and only one of them belongs in git:

| | Where it lives |
|---|---|
| **Config** (text) | this repo, symlinked into `~` by stow — portable to any machine/distro |
| **Binaries/tools** | never in git; a *recipe* that re-fetches them (`mise config.toml`, `scripts/`) |
| **Secrets** (ssh keys, tokens) | separate, **never** in this repo |
| **State/data** (history, caches, projects) | not reproduced |

**Cross-distro:** mise-managed tools are byte-identical on Ubuntu/Fedora/Arch — mise downloads its own binaries from each tool's upstream. Only the small apt layer in `scripts/` changes per distro. Nix (the future capstone) would make even that identical.

## Install on a fresh machine

Prerequisites, once by hand:
- A **Nerd Font** installed on the host and selected in the terminal (this setup uses **Hack Nerd Font**). Until then, prompt and file icons render as boxes (□).
- GitHub access to push (`gh auth login`, or an SSH key on the account).

Clone to `~/.dotfiles` — the scripts assume that path:

    git clone https://github.com/arpaad/dotfiles.git ~/.dotfiles

Then run, in order:

    scripts/00-backup.sh            # me  · back up ~/.bashrc
    scripts/01-apt-base.sh          # YOU · sudo: core packages (git, make, stow, curl, unzip, zsh)
    scripts/02-apt-system-tools.sh  # YOU · sudo: podman + newer git (ppa)
    scripts/03-mise.sh              # me  · install mise + CLI toolkit        (long download)
    scripts/04-ohmyzsh.sh           # me  · oh-my-zsh + plugins
    scripts/05-link-configs.sh      # me  · stow zsh/starship/git into ~
    scripts/06-set-login-shell.sh   # YOU · chsh to zsh, then open a NEW WSL window
    scripts/07-runtimes.sh          # me  · go/node/uv via mise + uv python   (long download)
    scripts/08-remove-old-go.sh     # YOU · sudo: remove old /usr/local/go (after verifying)

`scripts/09-retire-nvm.sh` was a one-time migration off nvm — **not needed on a fresh machine.**

Then link the rest: `cd ~/.dotfiles && stow tmux nvim`.

## Stow packages

    ~/.dotfiles/
    ├── zsh/        .zshrc
    ├── starship/   .config/starship.toml
    ├── mise/       .config/mise/config.toml
    ├── git/        .gitconfig
    ├── tmux/       .config/tmux/tmux.conf
    ├── nvim/       .config/nvim/
    └── scripts/    (not a stow package)

The repo lives directly in `~` on purpose: stow's default target is the *parent* of the stow
directory, so `cd ~/.dotfiles && stow zsh` needs no flags. (The scripts still pass `-d`/`-t`
explicitly so they don't depend on the current directory.)

## What gets installed

**System packages (apt):**
`ca-certificates`, `software-properties-common`, `curl`, `unzip`, `git`, `build-essential` (make/gcc), `stow`, `zsh`, `podman`, plus newer `git` from `ppa:git-core/ppa`.

**Dev tools (mise) — see `mise/.config/mise/config.toml`:**
- runtimes: `node`, `go`, `uv`
- prompt: `starship`
- CLI: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `delta`, `lazygit`, `yazi`, `jq`, `btop`, `tealdeer` (tldr)
- also: `tmux`, `neovim`

**Shell:** oh-my-zsh + zsh-completions + zsh-autosuggestions + zsh-syntax-highlighting.
Toggle any plugin by commenting its line in the `plugins=(...)` array in `zsh/.zshrc`.

**Python interpreters:** managed by uv (`uv python install 3.14`).

## Design decisions (and why)

| Area | Decision | Why |
|---|---|---|
| Distro | Stay on **Ubuntu 24.04** (WSL) | Reproducibility comes from this repo, not distro-hopping |
| Shell | **zsh + oh-my-zsh** | Matches the work environment |
| Prompt | **starship** | Cross-shell, single TOML file — chosen over powerlevel10k |
| Tools | **mise-first** | One manager for runtimes + CLI; keep as little outside it as possible |
| Python | **uv** owns interpreters | System `python3` (3.12) left untouched forever — the OS depends on it |
| Dotfiles | plain **git repo + GNU stow** | Wanted recreate-from-repo, not live sync (so not chezmoi) |
| Editor | **Neovim + LazyVim** | |
| Multiplexer | **tmux** | Prefix remapped to `Ctrl-a` |
| Endgame | **Nix + home-manager** | Deliberate future capstone (Phase 6), with mentors at work |

Because tools come from **mise, not apt**, binaries keep their **real names** — `bat`, `fd`, `rg` —
with none of Debian's renames (`batcat`, `fdfind`). So the alias is simply `cat='bat'`.

## Aliases (interactive-only → `#!/bin/bash` scripts are unaffected)

```zsh
alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'
alias cat='bat'
# cd  -> smart cd (zoxide), learns dirs
# cdi -> interactive fuzzy dir jump (zoxide + fzf)
```

Escape hatch: `\ls`, `command cat`, etc. give the originals.

## Handy

- **tmux** prefix `Ctrl-a` — split `Ctrl-a |` / `Ctrl-a -`, reload `Ctrl-a r`
- **Neovim** — the first time you open a file of a new language, Mason auto-installs that LSP (one-time per language)
- Reset zoxide DB: `rm ~/.local/share/zoxide/db.zo`
- Roll back the login shell: `chsh -s /usr/bin/bash`
- mise-managed tools are only on `PATH` once `mise activate` runs (it's in `zsh/.zshrc`, with `~/.local/bin` first so fresh tabs find mise)

## Notes

- Nothing is deleted before its replacement is verified.
- System `python3` (3.12) is never touched — the OS depends on it.
- The full rebuild runbook and its status log (`env.plan.md`, `env.state.md`) were folded into this
  README once the rebuild finished; they remain in git history at commit `a43ffb5` if the detailed
  decision log is ever needed.
