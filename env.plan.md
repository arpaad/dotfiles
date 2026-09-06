# Environment Rebuild Plan

A reproducible, portable, terminal-centric dev environment on **WSL Ubuntu 24.04**.
Everything we discussed and decided, as a runbook to implement **tomorrow**.

- **Machine:** WSL2, Ubuntu 24.04.3 LTS (host `LuckyLap`) — *staying on Ubuntu, not reinstalling.*
- **Goal:** recreate the whole environment on any new machine (PC, Raspberry Pi, mini-PC server) from **one git repo**.
- **Dotfiles repo:** https://github.com/arpaad/dotfiles.git
- **Workflow:** ~80% terminal (with Claude Code) + ~20% VS Code; learning Neovim.

---

## ⚠️ WHAT YOU MUST DO (manual tasks)

I'll do all the user-space work. These are the only bits that need **you** (password, Windows-side, or a new shell). *I'll tell you exactly when each one is due — don't run them ahead of time.*

- [ ] **Phase 0 — Nerd Font (do anytime, needed for icons):** install **Hack Nerd Font** on Windows → Windows Terminal → Settings → your Ubuntu profile → Appearance → *Font face* → "Hack Nerd Font" → **restart the terminal**. Until this is done, prompt/file icons show as boxes (□).
- [ ] **Phase 0 — GitHub access:** make sure you can push to `arpaad/dotfiles` (either `gh auth login`, or an SSH key added to GitHub). Create the empty repo on GitHub if it doesn't exist yet.
- [ ] **Phase 1 — base packages (sudo/password):**
  `sudo apt update && sudo apt install -y zsh build-essential stow curl unzip`
- [ ] **Phase 1 — make zsh your login shell (password):**
  `chsh -s $(which zsh)` → then **open a new WSL session** for it to take effect.
- [ ] **Phase 2 — remove old manual Go (sudo, only AFTER mise's go is verified):**
  `sudo rm -rf /usr/local/go`
- [ ] **Optional — terminal color scheme:** pick one in Windows Terminal (Catppuccin / Tokyo Night / Gruvbox pair nicely with starship + nvim).

Everything else below, I run for you (with `.bashrc` backed up first, so bash keeps working the whole time).

---

## Locked decisions

| Area | Decision |
|---|---|
| Distro | Stay on **Ubuntu 24.04** (WSL). Reproducibility via repo, not distro-hopping. |
| Shell | **zsh + oh-my-zsh** (matches work) |
| Prompt | **starship** (cross-shell, single TOML — chosen over powerlevel10k) |
| zsh plugins | zsh-autosuggestions, zsh-syntax-highlighting |
| Tools/runtimes | **mise-first** — manage as much as possible via mise; keep as little outside it as possible |
| Python | **uv** owns Python interpreters; system `python3` (3.12) left untouched forever |
| Dotfiles | plain **git repo** + **GNU stow** symlinks (NOT chezmoi) |
| Editor | **Neovim + LazyVim** |
| Multiplexer | **tmux** |
| Reproducibility endgame | **Nix + home-manager** later (Phase 6), with work mentors |

---

## Reproducibility model (how recreate works)

A "system" splits into two kinds of thing:

- **Config = text →** lives in the **git repo**, symlinked into `~` by stow. Portable to any machine/distro.
- **Binaries/tools →** never stored in git; stored as a **recipe** that re-fetches them:
  - `mise config.toml` → runtimes + CLI tools (downloaded from each tool's official upstream, distro-agnostic).
  - `bootstrap.sh` → the tiny apt base layer (zsh, build-essential, stow…).
- **Secrets** (ssh keys, tokens) → separate, **never** in the repo.
- **State/data** (history, caches, projects) → not "reproduced".

**Cross-distro:** mise-managed tools are identical on Ubuntu/Fedora/Arch (mise downloads its own binaries); only the small apt/dnf/pacman part of `bootstrap.sh` changes. Nix (later) makes even that identical.

### Repo layout (stow packages)
```
~/dev/dotfiles/
├── bootstrap.sh
├── zsh/        .zshrc
├── starship/   .config/starship.toml
├── mise/       .config/mise/config.toml
├── git/        .gitconfig
├── tmux/       .config/tmux/tmux.conf   (Phase 3)
└── nvim/       .config/nvim/            (Phase 4)
```
`cd ~/dev/dotfiles && stow zsh starship mise git` symlinks each package's files into `~`.

---

## Aliases (all interactive-only → scripts unaffected)

> Note: because we install via **mise** (not apt), binaries keep their **real names** — `bat`, `fd`, `rg` — with **no Debian renames** (`batcat`/`fdfind` are an apt-only annoyance we avoid). So the alias is simply `cat='bat'`.

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

---

## Current inventory (before)

- Ubuntu 24.04.3 LTS, WSL2; login shell still bash (132-line `.bashrc`).
- Claude Code 2.1.261 (latest) — global npm under **nvm** node v24.20.0.
- node v24.20.0 / npm 12.0.2 / corepack 0.36.0 / nvm 0.40.7.
- Go 1.27.1 at `/usr/local/go` (manual); `GOTOOLCHAIN=auto`; tools in `~/go/bin` (gopls, goimports, golangci-lint v2, goreleaser v2, protoc-gen-go/-grpc).
- python3 3.12.3 (apt); uv used & liked.
- git 2.55.0 (ppa:git-core/ppa); podman 4.9.3 (staying); VS Code 1.133.0 (Windows).
- Not yet installed: zsh, starship, oh-my-zsh, mise, stow, tmux, neovim, CLI toolkit.

---

## Phased implementation

### Phase 0 — Nerd Font + repo access  *(you — see must-do list)*

### Phase 1 — Repo + shell + CLI toolkit

**1. Backup + repo scaffold** *(me)*
```bash
cp ~/.bashrc ~/.bashrc.pre-rebuild
mkdir -p ~/dev/dotfiles/{zsh,starship,mise/.config/mise,git,tmux/.config/tmux,nvim/.config}
cd ~/dev/dotfiles && git init -b main
git remote add origin git@github.com:arpaad/dotfiles.git   # or https
```

**2. Base packages** *(you — sudo)*
```bash
sudo apt update && sudo apt install -y zsh build-essential stow curl unzip
```

**3. Install mise** *(me)*
```bash
curl https://mise.run | sh
```

**4. mise config — runtimes + toolkit** *(me)* → `mise/.config/mise/config.toml`
```toml
[tools]
# runtimes (Phase 2 fills these in)
node = "24"
go   = "1.27"
uv   = "latest"
# CLI toolkit
starship  = "latest"
fzf       = "latest"
ripgrep   = "latest"
fd        = "latest"
bat       = "latest"
eza       = "latest"
zoxide    = "latest"
delta     = "latest"   # git-delta; verify name via `mise registry | grep delta`
lazygit   = "latest"
yazi      = "latest"
jq        = "latest"
btop      = "latest"
tealdeer  = "latest"   # tldr client
```
```bash
mise install     # verify exact registry names first with: mise registry | grep <tool>
```

**5. oh-my-zsh + plugins** *(me)*
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions     $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```
> (The plugin clones also go into `bootstrap.sh` so a fresh machine re-fetches them.)

**6. Configs** *(me)*

`zsh/.zshrc`:
```zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                       # disabled — starship is the prompt
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

eval "$(mise activate zsh)"        # runtimes/tools on PATH
eval "$(starship init zsh)"        # prompt
eval "$(zoxide init zsh --cmd cd)" # cd = smart cd, cdi = interactive
source <(fzf --zsh) 2>/dev/null    # fzf keybindings (Ctrl-R/Ctrl-T) + completion

alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'
alias cat='bat'

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
```

`starship/.config/starship.toml` — start from the Nerd Font preset, then tweak:
```bash
starship preset nerd-font-symbols -o ~/dev/dotfiles/starship/.config/starship.toml
```

`git/.gitconfig` — wire delta as pager:
```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    line-numbers = true
[merge]
    conflictstyle = zdiff3
```

**7. Stow + login shell** *(me stows; you chsh)*
```bash
cd ~/dev/dotfiles && stow zsh starship mise git
chsh -s $(which zsh)      # YOU — password; then open a NEW WSL session
```

**8. bootstrap.sh + commit** *(me)* — a script that re-does apt + mise + oh-my-zsh + plugin clones + stow on a fresh machine. Then:
```bash
git add -A && git commit -m "Phase 1: shell + CLI toolkit" && git push -u origin main
```

### Phase 2 — Runtimes via mise
```bash
mise use -g go@1.27 node@24 uv@latest
uv python install 3.14        # uv owns Python interpreters
mise doctor                   # verify PATH precedence (mise shims win)
go version && node --version  # confirm they resolve to mise
```
Then retire manual Go:
```bash
sudo rm -rf /usr/local/go     # YOU — sudo, AFTER the checks above pass
# me: remove GOROOT / /usr/local/go PATH lines from .bashrc
git add -A && git commit -m "Phase 2: runtimes via mise" && git push
```
*(nvm stays until Phase 5. `~/go/bin` tools keep working — they're GOPATH binaries.)*

### Phase 3 — tmux
- Install tmux, write `tmux/.config/tmux/tmux.conf` (sane prefix, mouse, vi copy, splits, status). Learn ~10 keybinds. Stow + commit.

### Phase 4 — Neovim + LazyVim
- Install neovim (via mise), bootstrap **LazyVim**, track `nvim/.config/nvim/` (incl. `lazy-lock.json` for reproducible plugins). lazygit already installed. Stow + commit.

### Phase 5 — Migrate Claude Code + cleanup  *(LAST — the running CLI)*
```bash
mise exec node@24 -- npm install -g @anthropic-ai/claude-code
which claude && claude --version     # confirm it resolves to mise's node
# then retire nvm:
nvm uninstall 24.16.0                 # old fallback
# (optional) remove nvm entirely + its .bashrc block once happy
git add -A && git commit -m "Phase 5: claude-code on mise, retire nvm" && git push
```

### Phase 6 — (future) Nix + home-manager
With work mentors. `config.toml` + `bootstrap.sh` translate cleanly into a flake; the dotfiles repo becomes home-manager-managed. Nix runs fine on WSL Ubuntu via the Determinate Systems installer (no NixOS needed).

---

## Notes / gotchas
- **Nothing deleted before it's replaced & verified.** Migrate → verify → clean up.
- **System `python3` (3.12) is never touched** — the OS depends on it.
- **Claude Code is migrated last** because it's the running CLI (currently under nvm's node).
- **mise avoids Debian renames** → real binary names (`bat`, `fd`, `rg`), so aliases stay simple.
- **Aliases are interactive-only** → your `#!/bin/bash` scripts are unaffected.
- `.bashrc.pre-rebuild` is your rollback if anything feels off.
- Verify mise tool names with `mise registry | grep <name>` before `mise install`.
