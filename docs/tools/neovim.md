# Neovim — LazyVim, LSP, and the review workflow

Config: `nvim/.config/nvim/` → `~/.config/nvim/`

This is the largest piece of the setup and the one with the steepest curve. It
is also the only part you can safely skip: everything else here works with any
editor.

---

## What it's for

Editing and — more to the point here — **reviewing** code without leaving the
terminal.

The whole configuration is built around one workflow: read a change, understand
it hunk by hunk, and stage the parts you agree with. That is why the git
plugins get more attention than anything else.

## Why this one

Versus VSCode: it runs in a terminal, so it works identically over SSH, in
tmux, in WSL, on a server. It starts in well under a second. Its config is text
in git rather than a settings UI plus an extensions list.

Versus plain Neovim from scratch: a working config is genuinely a weekend, and
then it is yours to maintain forever.

Versus LazyVim (what is used here): a curated, pinned, documented set of
plugins that works on first launch, with clean seams for adding your own. The
trade is that you inherit someone else's opinions about ~80 plugins — which is
fine until you disagree, at which point you need to know how LazyVim's spec
merging works.

**The honest caveat:** modal editing costs about a week of being slower before
it pays back. If you are not prepared to spend that week, the rest of this repo
is more valuable per minute invested.

---

## How it's configured

Four files of yours, on top of LazyVim.

```
nvim/.config/nvim/
├── lazyvim.json          which LazyVim "extras" are on
├── lazy-lock.json        every plugin, pinned to an exact commit
├── lua/config/
│   ├── options.lua       editor options + the Python LSP choice
│   ├── keymaps.lua       the Hungarian-layout bracket aliases
│   ├── autocmds.lua
│   └── lazy.lua          bootstrap
└── lua/plugins/          one file per concern
    ├── colorscheme.lua   reads the shared palette
    ├── git.lua           diffview — the review view
    ├── lsp.lua           language server tuning
    ├── markdown.lua      four ways to view a document
    ├── treesitter.lua    extra parsers
    └── yazi.lua          file manager in a float
```

### `lazyvim.json` — the language support

LazyVim ships optional bundles called **extras**; this file records which are
enabled. Each one pulls in the language server, formatter, linter and
treesitter parser for its language in one line.

| Extra | Gives you |
|---|---|
| `lang.go` `lang.python` `lang.typescript` | full LSP, formatting and linting for those languages |
| `lang.json` `lang.toml` `lang.yaml` | schema-aware completion and validation for config files |
| `lang.markdown` | markdown tooling |
| `editor.snacks_picker` `editor.snacks_explorer` | the fuzzy finder and file tree |
| `ui.treesitter-context` | **sticky headers** — the enclosing function stays pinned to the top of the window while you scroll its body |

Add or remove extras with `:LazyExtras` rather than editing the file by hand.

### `lazy-lock.json` — why the plugin set is reproducible

Every plugin pinned to an exact commit. This is the file that makes
"reinstall on a new machine" give you the *same* editor rather than whatever
upstream shipped this week. `:Lazy update` moves the pins; committing the
result is how you record the upgrade.

**No plugin code is committed** — only the pins. Same rule as the rest of the
repo.

### `options.lua` — the Python type checker

The one substantive option:

```lua
vim.g.lazyvim_python_lsp = "basedpyright"
```

LazyVim defaults to `pyright`. `basedpyright` is a drop-in fork that adds inlay
hints and better inference, removes telemetry, and is fully open source.
`lsp.lua` pins its strictness to `"standard"`, because its own default
(`"recommended"`) is noisy enough to train you to ignore diagnostics.

The file also documents the planned successor — `ty`, from the uv/ruff people —
and notes that switching is one line, since LazyVim wires the rest
automatically. It is not the default yet because at 0.0.x its diagnostic
coverage is incomplete, and a checker that misses things is worse than none.

### `keymaps.lua` — the Hungarian bracket aliases

Vim leans hard on `[` and `]` for "previous/next thing" — `]h` next hunk, `]d`
next diagnostic, `]c` next change. On a Hungarian layout those are **AltGr
chords**, which makes the most-repeated motions in the editor a two-hand
operation.

So `é á ő ú` are mapped as aliases for `[ ] { }`:

| Press | Means |
|---|---|
| `á h` / `é h` | next / previous changed hunk |
| `á d` / `é d` | next / previous diagnostic |

```lua
vim.keymap.set({ "n", "x", "o" }, lhs, rhs, { remap = true, desc = ... })
```

`remap = true` is the load-bearing part: it lets `á h` resolve *through* to
whatever plugin has bound `]h`, so aliases keep working for mappings added
later. The real brackets still work.

If you are on a US layout, delete this file — it is the one piece here that is
purely a keyboard accident.

### `git.lua` — the review view

This is the centre of the setup.

LazyVim already gives you gitsigns (hunk markers in the gutter, stage/reset a
hunk, `Space g g` for lazygit). What it lacks is a **whole-change** view, which
`diffview.nvim` adds:

| Keys | Does |
|---|---|
| `Space g v v` | every uncommitted change, side by side, file list on the left |
| `Space g v b` | the whole branch versus its base |

The base branch is detected rather than hardcoded: it asks the remote what its
default branch is (`refs/remotes/origin/HEAD`), falls back to a local `main` or
`master`, and finally to `HEAD`. So it works in a repo that uses either name,
and in one with no remote.

### `markdown.lua` — four ways to read a document

| Keys | Gives you |
|---|---|
| `Space m r` | render **in place** — headings and tables styled, source still editable |
| `Space m p` | side by side: source left, glow's render right, refreshed on save |
| `Space m g` | full-screen scrollable read via glow |
| `Space m b` | live browser preview |

Four because they suit different moments — writing, checking, reading, and
showing someone. Compared properly in
**[the markdown tutorial](../tutorials/markdown.md)**.

### `treesitter.lua` — extra parsers

Appends `make`, `gitcommit`, `gitignore`, `git_rebase` and `gitattributes` to
LazyVim's defaults. Makefiles have no good language server, but a parser alone
still buys correct highlighting, indentation and folding.

It uses `opts_extend`, so the list is **appended** to LazyVim's rather than
replacing it — the standard trap when overriding a LazyVim spec.

### `colorscheme.lua` — reads the palette

Loads the colorscheme named by `THEME_NVIM` in
`~/.config/theme/palette.env`, so the editor is themed from the same file as
`ls` and `git diff` rather than being set separately.

### `yazi.lua`

`Space y` opens yazi in a floating window, and opening a file there returns you
to the editor. See [Navigation](navigation.md).

---

## The keys worth knowing on day one

Leader is `Space`. **Press it and wait** — a menu of every valid next key
appears. That menu is the real documentation.

| Keys | Does |
|---|---|
| `Space Space` | find file by name |
| `Space /` | search across the project (ripgrep) |
| `Space e` | file tree |
| `g d` / `Ctrl-o` | go to definition / jump back |
| `Space c a` | code action (fix, import, refactor) |
| `Space c r` | rename symbol, project-wide |
| `Space g v v` | review every uncommitted change |
| `Space g h p` / `Space g h s` | preview / stage a hunk |
| `Space g g` | lazygit, full screen |
| `Space y` | yazi in a float |

Language servers install themselves via Mason the first time you open a file of
a new language — nothing to set up in advance.

Full walkthrough, written for someone coming from VSCode who has never used a
modal editor: **[the Neovim tutorial](../tutorials/neovim.md)**.

---

## Related

- [Git](git.md) — the CLI side of the same review workflow
- [tmux](tmux.md) — `escape-time 10`, without which `Esc` lags in here
- [the palette](../theme/README.md) — where the colorscheme comes from
