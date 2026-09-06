# Installing — what has to exist by hand

Almost everything in this setup is portable: one `mise` file fetches the whole
toolchain, and the configs are plain text that works on any Linux or macOS.

What is **not** portable is the small layer underneath — the system packages,
the shell framework, and the font. That layer is what this page lists, and it
is the only part that differs between distributions.

---

## Pick your path

| You are on | Go to |
|---|---|
| **Ubuntu / Debian**, including WSL | **[ubuntu-wsl.md](ubuntu-wsl.md)** — scripted, ~15 minutes |
| **Fedora / RHEL**, or anything else | **[fedora.md](fedora.md)** — the same list, `dnf` names, done by hand |
| *just want to try the tools*, not adopt a repo | [below](#trying-it-without-adopting-anything) |

---

## The by-hand layer

Seven things. Everything else in the repo is downstream of them.

| # | What | Why it's needed | Notes |
|---|---|---|---|
| 1 | **A Nerd Font** | `eza --icons` and the starship prompt draw glyphs that only exist in a patched font | Installed on the machine running the **terminal emulator** — on WSL that means Windows, not the Linux side. Skip it and you get □ boxes, but nothing breaks |
| 2 | **Base build tools** — `curl`, `git`, `unzip`, a C toolchain | mise's installer needs curl; some tools compile | your package manager's standard names |
| 3 | **`stow`** | symlinks this repo's configs into `~` | only needed if you adopt the repo. Copying the files by hand works too |
| 4 | **`zsh`** | the shell everything else assumes | your package manager |
| 5 | **oh-my-zsh + 3 plugins** | `.zshrc` as written loads them | one installer script, then three `git clone`s. → [Shell](../tools/shell.md) |
| 6 | **`mise`** | installs the entire rest of the toolchain | `curl https://mise.run \| sh` — lands in `~/.local/bin`, no sudo |
| 7 | **zsh as your login shell** | so a terminal starts in zsh | `chsh`. **Takes effect on the next login, not the next tab** |

Two more that are genuinely optional:

- **A newer git.** Distro git works fine; the Ubuntu path adds a PPA only
  because 24.04 ships 2.43 and delta's nicer behaviours want newer.
- **podman.** Rootless containers. Nothing here depends on it — it is in the
  Ubuntu script because it was wanted on that machine, not because the setup
  needs it.

Once items 2–6 exist, the rest is identical everywhere:

```sh
mise install                              # the whole toolchain
stow -d ~/.dotfiles -t ~ zsh starship ... # the configs
nvim                                      # let LazyVim install its plugins
scripts/04-theme.sh                       # apply the palette
```

---

## The order, and why it matters

Three ordering constraints will bite you if you improvise:

1. **`chsh` needs a new *login*, not a new tab.** Close the whole terminal.
   `getent passwd $USER` should end in `zsh`.
2. **`scripts/04-theme.sh` must run after Neovim has started once.** It copies
   themes out of `tokyonight.nvim`'s own `extras/` directory, which does not
   exist until lazy.nvim has cloned the plugin. → [the palette](../theme/README.md)
3. **`ya pkg install` needs the yazi config stowed first.** It reads the plugin
   pins from `yazi/.config/yazi/package.toml`.

---

## Trying it without adopting anything

If you already have a zsh you like, you do not need this repo, the scripts, or
stow. The toolkit is independent of all of it:

```sh
curl https://mise.run | sh
mise use -g eza bat fd ripgrep fzf zoxide delta lazygit glow jq btop
```

Then add to your own `.zshrc`:

```zsh
eval "$(mise activate zsh)"
eval "$(zoxide init zsh --cmd cd)"
source <(fzf --zsh)

alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias cat='bat'
alias md='glow -p'
```

That is most of the daily benefit, in ten lines, with nothing to uninstall
later. What each line does: **[the catalog](../tools/README.md)**.

To go further, take pieces one at a time — every file in this repo is
standalone. `git/.gitconfig` needs nothing but delta; `tmux/.config/tmux/tmux.conf`
needs nothing but tmux.

---

## Removing it

```sh
cd ~/.dotfiles && stow -D zsh starship git tmux nvim mise yazi eza theme bat lazygit
chsh -s /bin/bash          # if you want bash back
rm -rf ~/.local/share/mise # the toolchain
```

The repo and your own files stay. Nothing here writes outside `~`.
