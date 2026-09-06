# Migrating this setup to Nix — a plan

Today this repo installs itself with **four package managers stacked on each
other**: `apt` for the system layer, `mise` for the toolchain, `stow` for the
config symlinks, plus `ya pkg` and `lazy.nvim` for their own plugins. Each is
fine alone. Together they are why `scripts/01` needs a rewrite per distro, why
`04-theme.sh` must run *after* Neovim has started once, and why "reproducible"
means "probably, if the network gives you the same versions".

**Nix collapses the first three into one file, one command, and a rollback.**

This page is the plan for getting there — in phases, each of which leaves you
with a working machine, and any of which you can stop at.

> **Read this first:** the honest verdict is at the [bottom](#is-it-worth-it).
> The short version: phases 1–4 are a clear win, phase 5 is a genuine trade,
> and none of it is urgent.

---

## The shape of the destination

Three decisions, made up front, because they determine everything else.

| Decision | Choice | Why |
|---|---|---|
| **NixOS, or Nix on top of Ubuntu?** | **Nix on top** | NixOS replaces your whole OS. You do not need that. Nix installs into `/nix` and manages `$HOME`; Ubuntu, WSL and apt keep working exactly as they do now |
| **What manages `$HOME`?** | **home-manager** | it is the piece that owns dotfiles, packages and services for one user. It is the direct replacement for `stow` + `mise` |
| **Flakes, or channels?** | **flakes** | a `flake.lock` pins nixpkgs to one commit — that is the actual reproducibility, and it is what makes this repo a recipe instead of a wish |

So: **Nix + home-manager + flakes, standalone, on Ubuntu/WSL.** The same
`flake.nix` then works on Fedora, Arch and macOS with no edits — which is the
thing `scripts/01-prepare.sh` cannot do.

---

## What replaces what

| Today | After | Notes |
|---|---|---|
| `scripts/01-prepare.sh` — apt, oh-my-zsh, `chsh` | mostly `home.packages` + `programs.zsh` | `chsh` survives; see [the sharp edges](#the-sharp-edges) |
| `mise/.config/mise/config.toml` — 16 CLI tools | `home.packages = with pkgs; [ ... ]` | versions pinned by `flake.lock`, not by `"latest"` |
| `scripts/02-setup.sh` — `stow` 11 packages | `home.file` / `xdg.configFile` | home-manager *is* a symlink manager. stow becomes redundant |
| `scripts/03-install.sh` | `home-manager switch` | one command, atomic, reversible |
| `scripts/04-theme.sh` — `envsubst` + `cp` from `lazy/` | a Nix module reading `${pkgs.vimPlugins.tokyonight-nvim}/extras` | kills the "run nvim once first" ordering trap outright |
| `node`, `go`, `uv` in mise | `home.packages`, or per-project `devShells` | mise stays useful for project-pinned runtimes → [Runtimes](../tools/runtimes.md) |
| `nvim/.config/nvim` + `lazy-lock.json` | **unchanged** | see [what stays out](#what-stays-out-of-nix) |
| `ya pkg install` for `piper.yazi` | `programs.yazi.plugins`, or unchanged | the plugin is already vendored and pinned. Low value, do it last |

---

## Phase 0 · Decide, and write it down (½ hour)

Before installing anything, answer two questions in a file, because they change
what phases 4 and 5 look like:

1. **Do the configs stay plain text you edit in place?** Today you edit
   `~/.dotfiles/zsh/.zshrc` and the change is live, because stow made a symlink
   to it. home-manager's default is different — it copies the file into the
   **read-only Nix store** and symlinks *that*, so editing needs a rebuild.
   There is a way to keep the old behaviour ([`mkOutOfStoreSymlink`](#phase-4--configs-stow--home-manager)),
   and you should decide deliberately, not discover it.
2. **How far into home-manager's `programs.*` modules do you want to go?**
   Writing `programs.git.delta.enable = true` is idiomatic Nix — and it means
   your `.gitconfig` is now generated Nix, not a file a stranger can read. That
   is a direct conflict with this repo's stated purpose. Phase 5 exists as a
   separate phase for exactly this reason.

---

## Phase 1 · Install Nix (½ hour)

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

The Determinate Systems installer is the one to use: it enables flakes by
default and, crucially, it ships a **working uninstaller** — which is the whole
reason this phase is low-risk.

```sh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --version
nix run nixpkgs#hello        # proves the binary cache works
```

**On WSL**, the daemon wants systemd. Check `/etc/wsl.conf` contains:

```ini
[boot]
systemd=true
```

then `wsl --shutdown` from Windows. Without it, pass `--init none` to the
installer and accept single-user mode.

**Stop-here value:** none yet. But `nix run nixpkgs#<anything>` now runs any of
100 000 packages without installing them, which is worth the half hour on its
own.

---

## Phase 2 · A flake that does almost nothing (1 hour)

The point of this phase is to prove the *loop* — edit, `switch`, roll back —
with something you do not care about, before you point it at your shell.

`flake.nix` at the repo root:

```nix
{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."lucky" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix/home.nix ];
      };
    };
}
```

`nix/home.nix`:

```nix
{ ... }:
{
  home.username      = "lucky";
  home.homeDirectory = "/home/lucky";
  home.stateVersion  = "25.05";     # set once, never bump casually

  programs.home-manager.enable = true;
}
```

Then:

```sh
nix run home-manager/master -- switch --flake ~/.dotfiles#lucky
git add flake.nix flake.lock nix/     # flake.lock IS the pinning. Commit it.
```

Now learn the escape hatch **before** you need it:

```sh
home-manager generations              # every past state, newest first
/nix/var/nix/profiles/per-user/$USER/home-manager-3-link/activate   # go back to #3
```

That is the thing mise and stow cannot do, and the reason the rest of the plan
is safe: every `switch` is a new generation, and every generation is one command
away.

---

## Phase 3 · The toolchain (mise → `home.packages`) (1 evening)

Replace the `[tools]` block of `mise/.config/mise/config.toml`:

```nix
home.packages = with pkgs; [
  # CLI toolkit — one line each, same list as mise/config.toml
  eza bat fd ripgrep fzf zoxide delta lazygit yazi jq btop glow tealdeer
  tmux neovim starship
];
```

```sh
home-manager switch --flake ~/.dotfiles#lucky
which eza     # → ~/.nix-profile/bin/eza
```

**Order matters in `.zshrc`.** Both mise's shims and `~/.nix-profile/bin` are on
`PATH` during the transition, so decide which wins and put it first. Cleanest is
to cut the migrated tools out of `config.toml` in the same commit, so there is
only ever one copy.

Two names to know: `fd` is `fd` in nixpkgs (not Fedora's `fd-find`), and
`tealdeer` provides the `tldr` command.

> **Stop-here value: high.** You now have the toolkit pinned by a lockfile
> instead of `"latest"`, identical on every machine, installable in one command,
> and rollable-back. That is most of the benefit of the whole migration, and you
> have not touched a single config file yet.

---

## Phase 4 · Configs (stow → home-manager) (1 evening)

home-manager does what stow does, so `scripts/02-setup.sh` disappears. The
question from phase 0 lands here — there are two ways to write it, and the
difference is the one thing in this plan that changes daily habits.

**The Nix-idiomatic way** — file is copied into the store, immutable:

```nix
xdg.configFile."starship.toml".source = ../starship/.config/starship.toml;
xdg.configFile."tmux/tmux.conf".source = ../tmux/.config/tmux/tmux.conf;
home.file.".zshrc".source = ../zsh/.zshrc;
```

Edit the repo → `home-manager switch` → the change appears. Nothing in `~` is
writable, so you cannot accidentally edit a symlink and lose the change. But
every tweak is a rebuild.

**The stow-compatible way** — a plain symlink back into the repo, no rebuild:

```nix
{ config, ... }:
let dotfiles = "${config.home.homeDirectory}/.dotfiles";
in {
  xdg.configFile."yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/yazi/.config/yazi";
}
```

Same behaviour you have today: edit the file, restart the tool, done.

**Recommendation:** `mkOutOfStoreSymlink` for what you actively tune —
`nvim/`, `yazi/`, `.zshrc` — and the store for what you set once and forget —
`starship.toml`, `tmux.conf`, `lazygit`. Migrate **one stow package per commit**
and remove its name from `PACKAGES` in `02-setup.sh` in the same commit, so the
two systems never both own a file. `stow -D <name>` first; a leftover stow
symlink makes `switch` abort with a clobber error, which is annoying but is Nix
being careful rather than Nix being broken.

> **Stop-here value: high.** `scripts/01` through `03` are now one command that
> works on any distro. This is the natural end of the migration.

---

## Phase 5 · The `programs.*` modules (optional — read phase 0 again)

home-manager can *generate* the configs rather than link yours:

```nix
programs.zsh = {
  enable = true;
  oh-my-zsh.enable = true;
  oh-my-zsh.plugins = [ "git" ];
  plugins = [ /* zsh-autosuggestions, zsh-syntax-highlighting from pkgs */ ];
};
programs.git.delta.enable = true;
programs.fzf.enableZshIntegration = true;
programs.zoxide = { enable = true; options = [ "--cmd cd" ]; };
```

What you gain: the three oh-my-zsh plugin `git clone`s in `scripts/01` become
declarative, and integration snippets stop being hand-copied `eval` lines.

What you lose, and it is not small:

- **It is either/or per file.** `programs.zsh.enable` generates `~/.zshrc`;
  you cannot also set `home.file.".zshrc"`. The heavily-commented `.zshrc` that
  [the shell page](../tools/shell.md) walks through line by line stops existing
  as a file anyone can read.
- **The repo stops being readable as configuration.** Its whole premise is that
  you can take one file and use it without Nix. Nix-generated config cannot be
  copy-pasted into someone else's `.zshrc`.

Do phase 5 for `fzf`, `zoxide` and `direnv` — glue you never read anyway. Think
hard before doing it for `zsh`, `git`, `tmux` and `nvim`, which are the parts
this repo is *about*.

---

## Phase 6 · The theme generator (½ day, and the most satisfying part)

`scripts/04-theme.sh` does two things Nix does better:

- It `cp`s six files out of `~/.local/share/nvim/lazy/tokyonight.nvim/extras/` —
  a path that only exists after Neovim has been run once. In Nix that directory
  is `${pkgs.vimPlugins.tokyonight-nvim}/extras`, which exists always, at a
  pinned revision. **The ordering constraint disappears.**
- It renders `eza-theme.yml.in` with `envsubst`. In Nix the palette is an
  attrset and the render is `pkgs.substituteAll` — evaluated at build time, so a
  missing `ROLE_` is a build error rather than the `grep 'foreground: ""'`
  guard the script needs today.

Sketch:

```nix
let
  palette = import ../nix/palette.nix;          # the ROLE_* block, as attrs
  extras  = "${pkgs.vimPlugins.tokyonight-nvim}/extras";
  style   = "tokyonight_${palette.tokyonightStyle}";
in {
  xdg.configFile."eza/theme.yml".source =
    pkgs.substituteAll ({ src = ../scripts/templates/eza-theme.yml.in; } // palette);
  xdg.configFile."yazi/theme.toml".source = "${extras}/yazi/${style}.toml";
  xdg.configFile."bat/themes/${style}.tmTheme".source =
    "${extras}/sublime/${style}.tmTheme";
}
```

The `sed 's/{ name = /{ url = /g'` fixup for yazi's schema rename stays — it
just moves into a `pkgs.runCommand`. And `bat cache --build` becomes a
home-manager activation script, which is the one genuinely awkward corner here,
since bat insists on a mutable cache directory.

---

## What stays out of Nix

Being clear about this is what keeps the plan finite.

| Stays | Why |
|---|---|
| **The Nerd Font** | it installs on whatever runs your *terminal emulator*. On WSL that is Windows. Nix cannot reach it |
| **`nvim/` and `lazy-lock.json`** | lazy.nvim already pins every plugin and does it well. Moving to `nixvim` is a rewrite of the editor config, not a migration — a separate project, if ever |
| **`podman`** | rootless podman on non-NixOS wants `subuid`/`subgid` and system paths. apt's version works; leave it |
| **`chsh`** | Nix installs zsh but cannot make it your login shell. Still one `chsh`, still effective on next login |
| **Secrets** | out of the repo now, out of it after. `sops-nix` exists if that ever changes |
| **mise, for projects** | a per-project `.mise.toml` pinning node 20 for one repo is still the right tool. Nix `devShells` are the eventual answer, and `nix-direnv` makes them automatic — but that is a phase 7 nobody needs yet |

---

## The sharp edges

Things that will cost you an hour if nobody warns you.

1. **`switch` refuses to clobber existing files.** Every file home-manager wants
   to own must not already exist. `stow -D` the package first, or use
   `-b backup`. This is the number-one first-run failure.
2. **`home.stateVersion` is not a version to keep current.** Set it to whatever
   is current on first install and leave it alone forever. It is a compatibility
   marker, not a channel.
3. **Login shell on non-NixOS.** `chsh -s ~/.nix-profile/bin/zsh` fails until
   that path is listed in `/etc/shells` — which needs sudo, once.
4. **`/nix` will be several GB** and grows with every generation. `nix-collect-garbage -d`
   deletes old generations (and with them your rollbacks). On WSL the vhdx does
   not shrink on its own; `wsl --manage <distro> --resize` or `Optimize-VHD`
   reclaims it from Windows.
5. **Nothing in `~/.nix-profile` is writable.** Tools that rewrite their own
   config on exit will fail. None in this toolkit do — but `bat`'s theme cache
   is why phase 6 needs an activation script.
6. **First `switch` on a cold cache downloads a lot.** Nothing compiles if you
   stay on `nixpkgs-unstable`; step off the beaten path and things build from
   source, slowly.

---

## Is it worth it?

**Yes for phases 1–4, and they are most of the value.** What you actually get:

- one command, one lockfile, and a machine that comes back identical — including
  on Fedora, Arch and macOS, which is the thing `scripts/01` cannot do
- versions pinned in git rather than `"latest"` resolved on install day
- a rollback, which nothing in the current setup has

**The cost is real and worth stating.** Nix's language is unlike anything else
you use, its error messages are poor, and a repo whose stated purpose is to be
**read rather than installed** gets harder to read the moment the shell config
is generated by a function instead of written in a file. That is not a reason
not to do it — it is a reason to stop after phase 4, keep the configs as plain
text that home-manager merely *links*, and let the Nix layer own installation
only.

The order to do it in, if you do it at all: **1 → 2 → 3, stop and live on it for
a month.** Phase 3 alone answers "can I rebuild this machine", which is the
question the whole repo exists to answer. Phases 4–6 are cleanup.

---

## Other distributions, without any of this

If you just want this setup on Fedora or Arch **today**, you do not need Nix.
Only `scripts/01-prepare.sh` is distro-specific — swap the apt line for your
package manager's names for `curl git unzip zsh stow` and a C toolchain, then
run `02`, `03` and `04` unchanged. The full by-hand list is in
**[installing](README.md#the-by-hand-layer)**.
