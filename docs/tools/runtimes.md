# Runtimes — mise, and where every binary comes from

Config: `mise/.config/mise/config.toml` → `~/.config/mise/config.toml`

One file declares the entire toolchain — every CLI tool on the other pages, plus
the language runtimes. `mise install` fetches the lot.

---

## mise

### What it's for

Installing and version-managing both **language runtimes** (node, go, python)
and **standalone CLI tools** (fzf, ripgrep, bat…), from one declarative file.

### Why not just use the distro's package manager?

This is the decision that shapes the whole repo, so it is worth stating
plainly. Four reasons:

**1 · Distro packages are old.** Ubuntu 24.04 ships eza 0.18 and git 2.43. The
tools on these pages are moving fast enough that a two-year-old version is
missing features the config uses.

**2 · Distro packages get renamed.** Debian and Ubuntu ship `bat` as
**`batcat`** and `fd` as **`fdfind`**, because of name collisions with unrelated
packages. Every tutorial, every README and every config example says `bat`. Via
mise you get the upstream name, which is why the alias in `.zshrc` is simply
`cat='bat'` and not a pile of per-distro conditionals.

**3 · One file, any distro.** The same `config.toml` produces the same
toolchain on Ubuntu, Fedora, Arch or macOS. Nothing in it is distro-specific —
which is precisely what makes this repo portable. Only the *bootstrap*
(see [installing](../install/README.md)) differs per system.

**4 · No sudo.** Everything lands in `~/.local/share/mise`. Nothing touches the
system, nothing conflicts with a package the OS depends on, and removing it all
is `rm -rf`.

The trade-off is real: you are trusting mise's registry and taking a second
package manager into your life. For *system* software — the kernel, the C
toolchain, podman — apt or dnf remains the right answer, and that is what this
repo uses them for.

### Why mise specifically

Versus `asdf`: mise is a single Rust binary, is much faster, needs no plugin
installation step, and reads the same `.tool-versions` files. Versus separate
managers (`nvm`, `pyenv`, `rustup`, `gvm`): one tool and one config instead of
five, each with its own shell hook.

### How it's configured

```toml
[tools]
node = "24"
go   = "1.27"
uv   = "latest"
...
```

| Pin style | Used for | Why |
|---|---|---|
| `"24"`, `"1.27"` | language runtimes | a major version you can rely on. A minor bump should not change how your code compiles |
| `"latest"` | CLI tools | they are leaf tools with no project depending on them; newest is what you want |

Activated by one line in `.zshrc`:

```zsh
eval "$(mise activate zsh)"
```

This is the load-bearing line in the whole shell config — it puts everything
below on `PATH`. Without it, most of this repo's aliases point at nothing.

**Adding a tool:** add a line, run `mise install`. Check the name exists first
with `mise registry | grep <name>`.

---

## What is in the list

### Runtimes

| Tool | Pinned | For |
|---|---|---|
| `node` | 24 | JS/TS, and the npm-installed CLIs that come with it |
| `go` | 1.27 | the Go toolchain. `$GOPATH/bin` is added to `PATH` in `.zshrc` |
| `uv` | latest | Python package **and interpreter** manager |

### Python is a special case

Python is **not** in the mise list. It is installed by uv:

```sh
uv python install --default 3.14
```

Two reasons. uv is already there for packages and environments, and having one
tool own both interpreters and packages avoids the classic split-brain where
your package manager and your version manager disagree about which Python is
in play.

`--default` makes it the `python` and `python3` in `~/.local/bin`, which is
first on `PATH`. **The system `python3` (3.12 on Ubuntu 24.04) is never
touched** — the OS itself depends on it, and replacing a distro's system Python
is how you break your package manager.

### Shell and editing

| Tool | For |
|---|---|
| `starship` | the prompt → [Shell](shell.md) |
| `neovim` | the editor → [Neovim](neovim.md) |
| `tmux` | multiplexer → [tmux](tmux.md) |

### The CLI toolkit

| Tool | Replaces / does | Documented in |
|---|---|---|
| `fzf` | fuzzy finder | [Navigation](navigation.md) |
| `fd` | friendlier `find` | [Navigation](navigation.md) |
| `eza` | `ls` with git status and icons | [Navigation](navigation.md) |
| `zoxide` | `cd` that learns | [Navigation](navigation.md) |
| `yazi` | TUI file manager | [Navigation](navigation.md) |
| `ripgrep` (`rg`) | faster, saner `grep` | [Reading](reading.md) |
| `bat` | `cat` with highlighting | [Reading](reading.md) |
| `glow` | renders markdown | [Reading](reading.md) |
| `jq` | JSON on the command line | [Reading](reading.md) |
| `tealdeer` (`tldr`) | example-first man pages | [Reading](reading.md) |
| `btop` | `top`, but legible | [Reading](reading.md) |
| `delta` | readable git diffs | [Git](git.md) |
| `lazygit` | TUI for git | [Git](git.md) |

---

## Taking just the tools

You do not need this repo to get the toolkit. Install mise, then:

```sh
mise use -g fzf ripgrep fd bat eza zoxide delta lazygit yazi jq btop glow tealdeer
```

Or copy the lines you want out of `mise/.config/mise/config.toml` into your own
`~/.config/mise/config.toml`. That plus a handful of aliases is 80% of the
daily benefit of everything documented here.

---

## Related

- [Shell](shell.md) — the `mise activate` line and `PATH` ordering
- [installing](../install/README.md) — what has to exist before mise can run
