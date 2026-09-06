# Reading — bat, glow, ripgrep, jq, tldr, btop

Six tools for looking at things: file contents, rendered documents, search
results, JSON, documentation, and the machine itself.

None of them have config files of their own — they are wired up through
`.zshrc` aliases and the shared palette. So this page is mostly *why*, and the
small number of settings that exist.

---

## bat — `cat` with syntax highlighting

### What it's for

Printing a file to the terminal.

### Why this one

`cat` gives you undifferentiated text. bat gives you the same text with syntax
colour, line numbers, git modification markers in the gutter, and paging when
the output is longer than the screen. For reading code — which is most of what
you do with `cat` — that is strictly more useful.

Where it is *not* better: piping. bat detects when its output is not a terminal
and turns everything off, so `cat file | grep x` still works. But if you want
to be certain, `command cat` is there.

### How it's configured

```zsh
alias cat='bat'
export BAT_THEME="$THEME_BAT"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

| Setting | Why |
|---|---|
| `alias cat='bat'` | interactive shells only; scripts are unaffected |
| `BAT_THEME` | comes from the shared palette — and **delta follows it too**, so diffs and file listings agree |
| `MANPAGER` | man pages, syntax-highlighted. `col -bx` strips groff's backspace-overstrike bolding, which would otherwise show as `^H` noise. `-p` = plain, no decorations |

Two things that will confuse you once:

- **bat only reads themes from its cache.** Dropping a `.tmTheme` into the
  themes directory does nothing until `bat cache --build` runs — which
  `scripts/04-theme.sh` does for you.
- **bat names a custom theme after the *filename***, not the `<name>` declared
  inside the file. Ours declares `TokyoNight` but answers only to
  `tokyonight_moon`. `bat --list-themes` is the source of truth.

---

## glow — markdown, rendered

### What it's for

Reading a markdown file as a *document* — styled headings, wrapped paragraphs,
drawn tables — rather than as source.

### Why this one

It renders in the terminal with no browser and no server, handles the full
CommonMark set, and follows the terminal's light/dark mode automatically.

### How it's configured

```zsh
alias md='glow -p'
```

`-p` pages the output, so long documents scroll instead of flooding scrollback.

**This is the one place the "familiar command keeps its meaning" rule is
deliberately broken**, and it is worth understanding why:

| Command | Shows you | On `## Heading` you see |
|---|---|---|
| `cat notes.md` | the **source**, syntax-highlighted | `## Heading` in colour |
| `md notes.md` | the **result**, rendered | a styled heading |

bat never renders and glow never shows source, so the two never overlap. They
are different questions, so they get different words rather than one word with
a flag.

glow is also what yazi shells out to for its markdown preview pane, and what
Neovim's `Space m g` opens. Four ways to look at a markdown file, compared:
**[the markdown tutorial](../tutorials/markdown.md)**.

---

## ripgrep (`rg`) — search inside files

### What it's for

Finding text across a codebase.

### Why this one

Speed is the headline, but the defaults are the real reason: `rg` respects
`.gitignore`, skips binaries, and searches recursively from the current
directory with no flags. `rg TODO` does what you meant. The `grep` equivalent
is `grep -rn --exclude-dir=node_modules --exclude-dir=.git TODO .`

`grep` is still the right tool inside a pipe, and it is still installed.

### Useful in practice

| Command | Does |
|---|---|
| `rg TODO` | every TODO in the tree, with file and line |
| `rg -i error` | case-insensitive |
| `rg -t go handler` | only Go files |
| `rg -l config` | just the filenames |
| `rg -C 3 panic` | three lines of context around each hit |

No configuration. It is also what Neovim's picker uses underneath, so a search
here and a search there return the same results.

---

## jq — JSON on the command line

### What it's for

Reading and reshaping JSON without opening an editor or writing a script.

### Why this one

It is the standard, it is a single binary, and every API example on the
internet already assumes it.

### Useful in practice

| Command | Does |
|---|---|
| `jq . file.json` | pretty-print and colourise — the 90% use |
| `curl -s url \| jq .` | the reason it is installed |
| `jq '.items[].name'` | pull one field out of an array |
| `jq -r '.token'` | **r**aw output: no surrounding quotes, for use in scripts |

No configuration.

---

## tealdeer (`tldr`) — the man page you actually wanted

### What it's for

Remembering how to use a command you have used before.

### Why this one

`man tar` is a specification. `tldr tar` is six examples, which is what you
actually need when you know the tool and forgot the flags. tealdeer is the fast
Rust client for the community `tldr-pages` database.

First run needs `tldr --update` to fetch the page cache.

`man` is still the right call when you need the complete truth — and with
`MANPAGER` set, it is now readable.

---

## btop — `top`, but legible

### What it's for

Seeing what is using CPU, memory, disk and network, and killing it.

### Why this one

Sortable, mouse-aware, with history graphs rather than a wall of numbers.
Practically it is the tool you open when something is slow and you want the
answer in three seconds.

### A note on its config

**btop is deliberately not themed or stowed**, and this is the one tool that
gets an exception. btop rewrites its own config file when it exits, so a stow
symlink into this repo would mean it edits the repo every time you close it.
Left alone, it keeps its own state in `~/.config/btop/` where it belongs.

---

## Related

- [Navigation](navigation.md) — `fd`, which pairs with `rg` (names versus contents)
- [the palette](../theme/README.md) — where `BAT_THEME` comes from
- [the markdown tutorial](../tutorials/markdown.md) — cat vs. md vs. yazi vs. Neovim
