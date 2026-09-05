# dotfiles

Reproducible terminal-centric dev environment for **WSL Ubuntu 24.04**.
Config lives here as real files, symlinked into `~` with GNU stow.
Binaries are a *recipe*: `mise/.config/mise/config.toml` (dev tools) + `scripts/` (system packages).

Every script is **flat**: one command per line, no conditionals / loops / functions — read top to bottom.

## Prerequisites (once, by hand)

- Nerd Font installed on the host and selected in the terminal — **done (Hack Nerd Font)**.
- GitHub access to push this repo (`gh auth login`, or an SSH key on the account).
- Clone this repo to `~/dev/dotfiles` (the scripts assume that path):

      git clone https://github.com/arpaad/dotfiles.git ~/dev/dotfiles

## What gets installed

**System packages (apt) — needed on any fresh machine:**
- `ca-certificates`, `software-properties-common`, `curl`, `unzip`
- `git`, `build-essential` (make / gcc), `stow`, `zsh`
- `podman`
- newer `git` from `ppa:git-core/ppa`

**Dev tools (mise) — see `mise/.config/mise/config.toml`:**
- runtimes: `node`, `go`, `uv`
- prompt: `starship`
- CLI: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `delta`, `lazygit`, `yazi`, `jq`, `btop`, `tealdeer` (tldr)

**Shell:** oh-my-zsh + zsh-completions + zsh-autosuggestions + zsh-syntax-highlighting.
Toggle any plugin by commenting its line in the `plugins=(...)` array in `zsh/.zshrc`.
**Python interpreters:** managed by uv (`uv python install 3.14`).

## Run order — Session A (shell + runtimes)

    scripts/00-backup.sh            # me  · back up ~/.bashrc
    scripts/01-apt-base.sh          # YOU · sudo: core packages (git, make, stow, curl, unzip, zsh)
    scripts/02-apt-system-tools.sh  # YOU · sudo: podman + newer git (ppa)
    scripts/03-mise.sh              # me  · install mise + CLI toolkit        (long download)
    scripts/04-ohmyzsh.sh           # me  · oh-my-zsh + plugins
    scripts/05-link-configs.sh      # me  · stow zsh/starship/git into ~
    scripts/06-set-login-shell.sh   # YOU · chsh to zsh, then open a NEW WSL window
    scripts/07-runtimes.sh          # me  · go/node/uv via mise + uv python   (long download)
    scripts/08-remove-old-go.sh     # YOU · sudo: remove old /usr/local/go (after verifying)

## Session B

- **tmux** — installed via mise (in `config.toml`). Link it: `stow -d ~/dev/dotfiles -t ~ tmux`. Prefix is `Ctrl-a`.
- **Neovim + LazyVim** — (coming) neovim via mise; `stow nvim`; first launch bootstraps plugins.
- `scripts/09-retire-nvm.sh` — one-time migration off nvm (not needed on a fresh machine).

## Notes

- Nothing is deleted before its replacement is verified.
- System `python3` (3.12) is never touched — the OS depends on it.
- Aliases are interactive-only, so `#!/bin/bash` scripts are unaffected.
- Rollback: `~/.bashrc.pre-rebuild` and `~/.gitconfig.pre-rebuild`.
