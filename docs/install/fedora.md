# Fedora (and other non-Debian systems)

The scripts in `scripts/` are written for Ubuntu — `apt`, a PPA, and WSL
assumptions. **Only `scripts/01-prepare.sh` is distro-specific.** Everything
after it is portable, so on Fedora you replace one script with about six
commands and then continue normally.

This page is also the right one if you are on Arch, openSUSE, or macOS — only
the package-manager names change.

---

## 1 · The system layer (replaces `scripts/01-prepare.sh`)

```sh
sudo dnf install -y git curl unzip zsh stow @development-tools ca-certificates
```

| Ubuntu package | Fedora equivalent | Why |
|---|---|---|
| `build-essential` | `@development-tools` | a C toolchain, for tools that compile |
| `software-properties-common` | *(not needed)* | that is an apt-repository helper |
| `git` from `ppa:git-core/ppa` | plain `git` | Fedora already ships a recent git — the PPA exists only because Ubuntu 24.04 is on 2.43 |
| `podman` | `podman` | optional, and unrelated to the rest |

### oh-my-zsh and its three plugins

Identical on every distro:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/zsh-users/zsh-completions        "$ZSH_CUSTOM/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-autosuggestions    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

What each plugin is for, and which to drop if you dislike it:
**[Shell](../tools/shell.md)**.

### Login shell

```sh
chsh -s "$(which zsh)"
```

Takes effect on the **next login** — close the terminal entirely, not just the
tab. Verify with `getent passwd $USER`.

### The font

Install a **Nerd Font** on whichever machine runs your terminal emulator and
select it in the emulator's profile. This config assumes **Hack Nerd Font**.

On Fedora:

```sh
sudo dnf install -y hack-nerd-fonts        # or: dnf search nerd-fonts
```

Without it, `eza --icons` and the prompt render as □ boxes. Nothing breaks; it
just looks wrong.

---

## 2 · Everything after this is identical

From here, follow **[ubuntu-wsl.md](ubuntu-wsl.md)** from step 2 onward, or run
the remaining scripts directly — none of them touch apt or need sudo:

```sh
git clone https://github.com/arpaad/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

scripts/02-setup.sh    # stow the configs into ~
scripts/03-install.sh  # mise + the whole toolchain + python + yazi plugins
```

Then open a new terminal, run `nvim` once so LazyVim installs its plugins, and:

```sh
scripts/04-theme.sh    # apply the palette to every tool
```

`scripts/02-setup.sh` **deletes `~/.zshrc` and `~/.gitconfig`** before
symlinking. Back them up first if they hold anything you want.

---

## SELinux, and other Fedora-specific notes

- **SELinux does not interfere.** Everything installs under `$HOME` with normal
  user permissions — no system paths, no services, no ports.
- **`~/.local/bin` is already on `PATH`** on Fedora, unlike Ubuntu. The
  `export PATH="$HOME/.local/bin:$PATH"` line in `.zshrc` is harmless
  duplication there, and still does the right thing: it ensures mise's
  binaries win over `/usr/bin` versions of the same names.
- **Fedora's own packages** exist for most of the toolkit (`dnf install eza bat
  fd-find ripgrep`) and are much fresher than Ubuntu's. You could use them
  instead of mise — but note Fedora also renames `fd` to **`fd-find`**, and
  you would be pinning nothing. The reasoning for mise either way:
  **[Runtimes](../tools/runtimes.md)**.
- **Not on WSL?** Ignore every mention of Windows in
  [ubuntu-wsl.md](ubuntu-wsl.md) — the font is then just a normal font install
  on the same machine.

---

## Don't want the whole thing?

Entirely reasonable. The toolkit works standalone on any distro:

```sh
curl https://mise.run | sh
mise use -g eza bat fd ripgrep fzf zoxide delta lazygit glow jq btop
```

plus ten lines in your existing `.zshrc` — see
[trying it without adopting anything](README.md#trying-it-without-adopting-anything).

Start with `eza` and the colour scheme; it is the piece that changes the most
per minute spent. **[What `ls` colours mean](../theme/eza-colours.md)**.
