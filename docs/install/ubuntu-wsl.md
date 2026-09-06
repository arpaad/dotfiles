# Install — Ubuntu / Debian (and WSL)

**This page is the Ubuntu-specific path.** On Fedora, RHEL, Arch or macOS,
only `scripts/01-prepare.sh` differs — swap its apt line for your package
manager's names and run steps 2 onward unchanged. For the distro-neutral list of
what has to be installed by hand, see **[installing](README.md)**; for the
one-file, any-distro version of all of it, see
**[migrating to Nix](nix.md)**.

The easy path: clone, run three scripts, open a new terminal, then one last
script. ~15 minutes, most of it downloads. Target is **WSL Ubuntu 24.04**; only
the apt section of `scripts/01` is distro-specific.

For what each piece *is*, why it was chosen, and how to take only parts of it,
see **[the catalog](../tools/README.md)**.

## 0 · Before you start

- **Install a Nerd Font on the host** (Windows, not WSL) and select it in your terminal.
  This config assumes **Hack Nerd Font** — download from
  [nerdfonts.com](https://www.nerdfonts.com/font-downloads), install, then set it in
  Windows Terminal → Settings → your Ubuntu profile → Appearance → Font face.
  Skip this and the prompt and file icons render as boxes (□).
- **`scripts/02` deletes `~/.zshrc` and `~/.gitconfig`** before symlinking. Copy them
  somewhere first if they hold anything you want.
- **`git/.gitconfig` has my name and email in it.** Change them before or after
  linking — see [After the install](#after-the-install).

## 1 · Clone

The scripts hardcode `~/.dotfiles`. Use that path.

```sh
git clone https://github.com/arpaad/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## 2 · Run the three scripts

Three phases, in order. **prepare** touches the system, **setup** links this repo's
configs into `~`, **install** fetches the toolchain. Each prints a `==>` banner per
step, so if one fails you can see exactly where it stopped.

| # | Script | sudo | What it does |
|---|---|---|---|
| 01 | `scripts/01-prepare.sh` | ✔ | apt base packages · `ppa:git-core/ppa` + podman · oh-my-zsh + 3 plugins · `chsh` to zsh |
| 02 | `scripts/02-setup.sh` | | deletes the default `~/.zshrc` + `~/.gitconfig`, then stows every package |
| 03 | `scripts/03-install.sh` | | installs mise · `mise install` (runtimes + CLI toolkit) · Python 3.14 via uv · `ya pkg install` (yazi plugins) |

`scripts/04-theme.sh` comes later, in step 4 — it needs Neovim to have installed its
plugins first.
| 02 | `scripts/02-setup.sh` | | deletes the default `~/.zshrc` + `~/.gitconfig`, then stows every package |
| 03 | `scripts/03-install.sh` | | installs mise · `mise install` (runtimes + CLI toolkit) · Python 3.14 via uv · `ya pkg install` (yazi plugins) |

`scripts/04-theme.sh` comes later, in step 4 — it needs Neovim to have installed its
plugins first.

```sh
scripts/01-prepare.sh
scripts/02-setup.sh
scripts/03-install.sh
```

All three run in your current bash shell — script 03 calls mise by its full path, so
nothing needs a restart mid-run.

## 3 · Open a new terminal

`chsh` only takes effect on a new login. Close the window, open a fresh WSL one — you
should land in zsh with the starship prompt.

Then open `nvim` once and let LazyVim install its plugins (a minute of scrolling output,
then `q` out of the lazy screen). Language servers install themselves via Mason the
first time you open a file of a new language.

## 4 · Apply the theme

```sh
scripts/04-theme.sh
```

This must come **after** step 3, because it copies themes out of
`tokyonight.nvim`'s own `extras/` directory — which does not exist until LazyVim
has installed it. It themes bat, yazi, fzf, delta, tmux, lazygit and eza from one
palette, and rebuilds bat's theme cache.

Open one more new terminal afterwards, so `.zshrc` picks up `BAT_THEME` and the
fzf colours. How it all fits together: **[the palette](../theme/README.md)**.

## 5 · Check it worked

```sh
which zsh starship mise     # all three found
mise ls                     # runtimes + CLI tools, all with versions
ls -l ~/.zshrc              # -> /home/<you>/.dotfiles/zsh/.zshrc
python --version            # 3.14.x   (system python3 is still 3.12 — untouched)
tmux                        # Ctrl-a | should split the window
bat --list-themes | grep tokyo   # tokyonight_moon  (theme cache was built)
ls -la ~/.dotfiles          # colours: dirs blue+bold, .md purple, lockfiles dim
bat --list-themes | grep tokyo   # tokyonight_moon  (theme cache was built)
ls -la ~/.dotfiles          # colours: dirs blue+bold, .md purple, lockfiles dim
```

## After the install

Set your own git identity — otherwise your commits are authored as me:

```sh
$EDITOR ~/.dotfiles/git/.gitconfig   # edit [user] name + email
```

Edit files **in `~/.dotfiles`**, never through the paths in `~`. They're the same file
via symlink, but committing from the repo is what keeps the machine reproducible.

## If something breaks

| Symptom | Fix |
|---|---|
| boxes (□) instead of icons | Nerd Font not installed or not selected in the terminal profile — see step 0 |
| `stow: ... existing target is not a symlink` | a real file is in the way: delete/move it, rerun the stow command |
| still in bash after step 3 | `chsh` needs a *new login*, not a new tab. Close the whole terminal. `getent passwd $USER` should end in `/usr/bin/zsh` |
| `mise: command not found` | mise lives in `~/.local/bin`; that's put on `PATH` by `zsh/.zshrc`, which only exists after script 02 |
| a tool is missing from `PATH` | `mise activate` runs from `.zshrc` — check you're in zsh, then `mise install` again |
| want bash back | `chsh -s /usr/bin/bash` |
| `ls` has no colours / wrong colours | `scripts/04-theme.sh` has not run, or you are in an old shell |
| `bat` warns `Unknown theme` | run `scripts/04-theme.sh` — bat only reads themes from its rebuilt cache |
| `04-theme.sh` says extras not found | open `nvim` once first so lazy.nvim installs tokyonight |
| markdown shows as plain text in yazi | `ya pkg install`, and check `which glow` |
| want it all gone | `cd ~/.dotfiles && stow -D zsh starship git tmux nvim mise yazi eza theme bat lazygit` unlinks everything; the repo and installed tools stay |
| `ls` has no colours / wrong colours | `scripts/04-theme.sh` has not run, or you are in an old shell |
| `bat` warns `Unknown theme` | run `scripts/04-theme.sh` — bat only reads themes from its rebuilt cache |
| `04-theme.sh` says extras not found | open `nvim` once first so lazy.nvim installs tokyonight |
| markdown shows as plain text in yazi | `ya pkg install`, and check `which glow` |
| want it all gone | `cd ~/.dotfiles && stow -D zsh starship git tmux nvim mise yazi eza theme bat lazygit` unlinks everything; the repo and installed tools stay |
