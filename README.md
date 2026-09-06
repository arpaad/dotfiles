# dotfiles

A reproducible, terminal-centric dev environment: zsh + starship, mise-managed toolchains,
tmux, and Neovim/LazyVim. Built for **WSL Ubuntu 24.04**; the only distro-specific part is
one apt script.

Config lives here as real files and is symlinked into `~` with GNU stow.
Binaries are never committed — they're a recipe that re-fetches them:
`mise/.config/mise/config.toml` for dev tools, `scripts/` for system packages.

## Install

**Before you start**

- Install a **Nerd Font** on the host and select it in the terminal — this config assumes
  **Hack Nerd Font**. Without it, prompt and file icons render as boxes (□).
- `scripts/05` replaces `~/.zshrc` and `~/.gitconfig`. Keep a copy if you have anything in them.

**Clone to `~/.dotfiles`** — the scripts assume this path:

    git clone https://github.com/arpaad/dotfiles.git ~/.dotfiles

**Run in order.** Scripts marked *sudo* prompt for your password.

    scripts/01-apt-base.sh          # sudo · core packages: git, build-essential, stow, curl, unzip, zsh
    scripts/02-apt-system-tools.sh  # sudo · podman + newer git from ppa:git-core/ppa
    scripts/03-mise.sh              #        install mise, link its config, fetch the CLI toolkit
    scripts/04-ohmyzsh.sh           #        oh-my-zsh + zsh plugins
    scripts/05-link-configs.sh      #        stow zsh, starship, git into ~
    scripts/06-set-login-shell.sh   # sudo · chsh to zsh

Then **open a new terminal** so zsh becomes your shell, and finish there:

    scripts/07-runtimes.sh          #        node/go/uv via mise + the default Python
    cd ~/.dotfiles && stow tmux nvim

**Check it worked**

    which zsh starship mise    # all present
    mise ls                    # runtimes and CLI tools installed
    ls -l ~/.zshrc             # -> .dotfiles/zsh/.zshrc

Open `nvim` once to let LazyVim install its plugins. Language servers install themselves
via Mason the first time you open a file of a new language.

## What you get

**System packages (apt)** — `ca-certificates`, `software-properties-common`, `curl`, `unzip`,
`git`, `build-essential`, `stow`, `zsh`, `podman`.

**Dev tools (mise)** — declared in `mise/.config/mise/config.toml`:

- runtimes: `node`, `go`, `uv`
- prompt: `starship`
- editor & multiplexer: `neovim`, `tmux`
- CLI: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `delta`, `lazygit`, `yazi`, `jq`, `btop`, `tealdeer`

**Shell** — oh-my-zsh with zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting.

**Python** — uv owns the interpreters (`uv python install --default 3.14`). The system
`python3` is never touched; the OS depends on it.

## Layout

    ~/.dotfiles/
    ├── zsh/        .zshrc
    ├── starship/   .config/starship.toml
    ├── mise/       .config/mise/config.toml
    ├── git/        .gitconfig
    ├── tmux/       .config/tmux/tmux.conf
    ├── nvim/       .config/nvim/
    └── scripts/    (not a stow package)

Each top-level directory is a **stow package** mirroring the paths it owns under `~`.
The repo sits directly in `~` because stow's default target is the *parent* of the stow
directory — so `cd ~/.dotfiles && stow zsh` needs no flags. (The scripts still pass `-d`/`-t`
explicitly so they work from any directory.)

## Conventions

- **Scripts are flat.** One command per line — no conditionals, loops, or functions. Readable
  top to bottom, and obvious where it stopped if one fails.
- **Config is text and goes in git. Binaries never do** — they're re-fetched from the recipe.
  Secrets (ssh keys, tokens) stay out of this repo entirely.
- **Tools come from mise, not apt**, so binaries keep their real upstream names — `bat`, `fd`,
  `rg`, not Debian's `batcat`/`fdfind`. That's why the alias is simply `cat='bat'`.
- **Aliases are interactive-only**, so `#!/bin/bash` scripts are unaffected.

## Aliases

```zsh
alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'
alias cat='bat'
# cd  -> smart cd (zoxide), learns the dirs you visit
# cdi -> interactive fuzzy dir jump (zoxide + fzf)
```

Escape hatch: `\ls`, `command cat` give you the originals.

## Changing things

| To… | Do this |
|---|---|
| add a CLI tool or runtime | add it to `mise/.config/mise/config.toml`, run `mise install` |
| add a system package | add it to `scripts/01` or `02` |
| turn a zsh plugin off | comment its line in the `plugins=(...)` array in `zsh/.zshrc` |
| link a new package | add the directory, then `cd ~/.dotfiles && stow <name>` |
| unlink one | `cd ~/.dotfiles && stow -D <name>` |

Edit files in this repo, never the symlinks' targets in `~` — they're the same file, but
committing from here is what keeps the machine reproducible.

## Reference

- tmux prefix is `Ctrl-a` — split `Ctrl-a |` / `Ctrl-a -`, reload config `Ctrl-a r`
- mise tools are on `PATH` only after `mise activate` runs; it's in `zsh/.zshrc`, with
  `~/.local/bin` ahead of it so a fresh shell can find mise itself
- reset the zoxide database: `rm ~/.local/share/zoxide/db.zo`
- go back to bash as login shell: `chsh -s /usr/bin/bash`
