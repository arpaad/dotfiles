# Navigation — eza, zoxide, fzf, fd, yazi

Five tools for one question: *where is the thing, and how do I get to it.*

They divide up cleanly — `eza` shows you what is here, `zoxide` takes you
somewhere you have been, `fzf` picks from a list, `fd` builds the list, and
`yazi` is the one you open when you'd rather look than type.

---

## eza — `ls`, but it answers more questions

Config: `eza/.config/eza/theme.yml` (generated) · aliases in `zsh/.zshrc`

### What it's for

Listing a directory.

### Why this one

Plain `ls` tells you names, and — if `LS_COLORS` is set — roughly eight
colours' worth of type information. eza adds three things that matter daily:

- **git status per file**, so `ll` tells you what you have changed without a
  separate `git status`
- **a themeable colour system with real granularity** — not eight colours but
  per-extension, per-filename rules
- **tree mode built in**, so no separate `tree` binary

The cost: it is not POSIX `ls` and never will be. A few flags differ. This is
why the alias is interactive-only and `\ls` still gets you the original.

### How it's configured

Four aliases, one per question you might be asking:

| Alias | Full command | Answers |
|---|---|---|
| `ls` | `eza --icons --group-directories-first` | what's here? |
| `ll` | `eza -l --icons --group-directories-first --git` | what's here, in detail, and what have I changed? |
| `la` | `eza -la ...--git` | same, including dotfiles |
| `lt` | `eza -T --icons --level=2 --group-directories-first` | what's the shape of this tree, two levels down? |
| `lg` | `eza -l --icons --git --git-repos` | which of these **sub-repositories** are dirty? |

| Flag | Why it's there |
|---|---|
| `--icons` | a filetype glyph before each name — a second, faster channel than reading the extension. **Requires a Nerd Font**, or you get boxes |
| `--group-directories-first` | directories at the top. You are usually looking for a directory to enter or a file to open, and separating them halves the scan |
| `--git` | a two-character column of git status per file |
| `--git-repos` | on `lg` only: for each *directory* that is its own repo, whether it is dirty. Useful in a folder full of checkouts |
| `-T --level=2` | tree, depth-limited. Unlimited depth in a repo with `node_modules` prints forever |

### The colours are the actual feature

The theme is **generated** from the shared palette — do not edit
`eza/.config/eza/theme.yml` by hand. It encodes four independent signals:

| Signal | Means |
|---|---|
| **hue** | what the file *is* — code, config, data, prose, secret |
| **bold** | you can **act** on it — enter it, run it, it's an entry point |
| **dim** | you can **ignore** it — generated, locked, vendored, cached |
| **underline** | something is **wrong or unsafe** — broken link, world-writable, merge conflict |

So `node_modules/` is dim grey rather than bold blue, a `.env` file is the
loudest thing on screen, and a directory you can usefully enter is bold. The
full legend, including what every column in `ll` means:
**[what `ls` colours mean](../theme/eza-colours.md)**.

---

## zoxide — `cd` that remembers

### What it's for

Getting to a directory you have been to before.

### Why this one

Typing paths is the single most repeated thing in a shell, and almost all of it
is repetition — you go to the same fifteen directories. zoxide keeps a
frecency-ranked database of where you actually go, so `cd dot` lands you in
`~/.dotfiles` from anywhere.

Versus `autojump`/`z`: same idea, but a single Rust binary with no dependencies
and an fzf-backed interactive mode. Versus plain `cd`: strictly additive — a
real path still behaves exactly like `cd`.

### How it's configured

```zsh
eval "$(zoxide init zsh --cmd cd)"
```

`--cmd cd` is the whole decision. Without it you get a new command called `z`;
with it, **zoxide takes over the name `cd`**.

| You type | What happens |
|---|---|
| `cd ~/projects/api` | a real path — behaves exactly like builtin `cd` |
| `cd api` | no such directory here, so zoxide jumps to the highest-ranked directory matching `api` |
| `cdi` | **i**nteractive: fuzzy-pick from the database with fzf |
| `cd -` | previous directory, as always |

Taking the name `cd` is the aggressive choice — the argument for it is that
you never have to remember which of two commands to use, and the fallback to
literal paths means it cannot strand you. `builtin cd` is the escape hatch.

The database is at `~/.local/share/zoxide/db.zo`; delete it to start over. It
is *not* in this repo — it is machine-local state, not config.

---

## fzf — the fuzzy picker everything else plugs into

### What it's for

Choosing one item from a long list, by typing fragments of it.

### Why this one

fzf is less a tool than a component. On its own it filters stdin. Its value is
that other tools hand it a list: zoxide hands it directories, the shell hands
it history, Neovim's picker uses the same interaction model. Learning one
filter-and-select gesture pays off in five places.

### How it's configured

```zsh
source <(fzf --zsh)
source ~/.config/theme/fzf.sh   # colours, from the shared palette
```

`fzf --zsh` installs the key bindings and completion. What you get:

| Key | Does |
|---|---|
| `Ctrl-R` | search shell history — the big one. Replaces scrolling up |
| `Ctrl-T` | insert a file path into the command line you are typing |
| `Alt-C` | cd into a subdirectory |
| `**<Tab>` | fuzzy completion for paths after any command |

`fzf.sh` appends colours to `$FZF_DEFAULT_OPTS` so the picker matches
everything else. It is generated — see [the palette](../theme/README.md).

Inside the picker: type to filter, `Ctrl-J`/`Ctrl-K` or arrows to move, `Enter`
to pick, `Esc` to cancel.

---

## fd — `find` you can remember

### What it's for

Finding files by name.

### Why this one

`find . -name '*.go' -not -path './vendor/*'` versus `fd -e go`. That is the
entire pitch. fd defaults to what you almost always want: skips `.gitignore`d
files and hidden files, is case-insensitive until you type a capital, and runs
in parallel.

It is also what feeds fzf a file list. `find` remains available for the cases
fd deliberately doesn't cover — `-exec` chains, mtime predicates, permission
tests.

### How it's configured

Nothing to configure. Worth knowing:

| Command | Does |
|---|---|
| `fd config` | every path containing "config" |
| `fd -e md` | every markdown file |
| `fd -H secret` | include hidden files |
| `fd -I node` | include ignored files |

---

## yazi — the file manager

Config: `yazi/.config/yazi/yazi.toml`, `theme.toml` (generated), `package.toml`

### What it's for

Moving around and looking at files with arrow keys and a preview pane, instead
of `ls` / `cd` / `cat` round-trips.

### Why this one

Honest framing: **yazi is not required by anything here, and a shell-native
workflow is often faster.** Where it genuinely wins is *exploring unfamiliar
territory* — a repo you have never seen, a directory of images or PDFs, or bulk
rename/move operations where you want to see what you are doing.

It earns its place because the preview pane makes a directory browsable at
reading speed. It is a Rust binary with async previews, so it stays responsive
in directories where an older manager would stall.

Launch it with **`y`**, not `yazi` — see the [`y` function](shell.md#y--yazi-that-changes-your-directory);
that is what makes your shell end up wherever you navigated to.

### How it's configured

```toml
[mgr]
sort_by         = "natural"   # file2 before file10
sort_dir_first  = true
show_hidden     = false       # toggle live with  .
show_symlink    = true
linemode        = "size"
ratio           = [1, 3, 4]
```

| Setting | Why |
|---|---|
| `sort_by = "natural"` | `file2` before `file10`. Lexical sort puts `file10` first, which is never what you meant |
| `sort_dir_first` | same reasoning as eza's `--group-directories-first` |
| `show_hidden = false` | dotfiles are noise while browsing. Press `.` to toggle when you actually want them |
| `linemode = "size"` | the right-hand column. `mtime` and `permissions` are the other useful values |
| `ratio = [1, 3, 4]` | parent / current / **preview**. The preview column is the widest — that is the deliberate bet: the preview is the reason to use yazi at all |

> **Gotcha:** the section is `[mgr]`. It was called `[manager]` until yazi 25.5.
> Older blog posts use the old name, and yazi **silently ignores it**.

### Previewers — markdown rendered in the pane

```toml
[[plugin.prepend_previewers]]
url = "*.md"
run = 'piper -- CLICOLOR_FORCE=1 glow -w=$w -s=$t "$1"'
```

`piper` is yazi's official plugin for piping any shell command's output into
the preview pane. Here it runs `glow`, so moving the cursor onto a `.md` file
renders it — headings, tables and all — with no keypress.

| Variable | Is |
|---|---|
| `$w` | the pane's actual width, so glow wraps to the real column count |
| `$t` | the terminal's theme: `dark`, `light` or `auto` |
| `$1` | the file being previewed |
| `CLICOLOR_FORCE=1` | glow is not writing to a terminal here, so it would strip colour without this |

`piper` is pinned in `package.toml` and fetched with `ya pkg install` — the
plugin is not vendored, only its exact revision is recorded.

### Openers — `Enter` edits, `O` reads

```toml
[open]
prepend_rules = [
  { url = "*.md", use = [ "edit", "glow", "reveal" ] },
]
```

First entry wins, so **`Enter` on a markdown file opens Neovim to edit it**.
Press **`O`** instead and you get the menu, including "Read with glow" —
full-screen and scrollable. The same source-versus-rendered split as `cat`
versus `md`.

Full walkthrough, including the keys: **[the yazi tutorial](../tutorials/yazi.md)**.

---

## Related

- [what `ls` colours mean](../theme/eza-colours.md) — the eza theme in full
- [Reading](reading.md) — bat and glow, which yazi and fzf both shell out to
- [Shell](shell.md) — where the aliases and the `y` function live
