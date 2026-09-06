# yazi, and where it actually fits

yazi is a **file manager**: a three-column browser with a live preview pane. It
is fast and pleasant, and it is the *smallest* of the three tools in your
workflow. Being honest about that up front will save you time.

> **What yazi does not do:** syntax-aware editing, LSP, and — importantly —
> **diffs**. Reviewing a change is a git operation, so that lives in Neovim
> (`Space g v v`) and lazygit (`Space g g`), not here. See
> [the Neovim tutorial](neovim.md).
>
> **What yazi is genuinely best at:** previewing files without opening them,
> moving and renaming things in bulk, and browsing *outside* the project you
> currently have open.

Verified against yazi **26.9.1**, the version mise installs.

---

## 0 · Two ways to launch it

### From the shell

```bash
y          # ← use this one
yazi       # also fine
```

`y` is a shell function in `zsh/.zshrc`. The difference: when you quit `y`, your
**shell ends up in whatever directory you browsed to**. Plain `yazi` leaves the
shell where it started. `y` is almost always what you want — it makes yazi a
navigation tool, not just a viewer.

Pressing `Enter` on a file opens it in **Neovim**, because `.zshrc` sets
`EDITOR=nvim`.

### From inside Neovim

```
Space y      open yazi in a floating window, cursor on the current file
Space Y      open yazi at the project root
```

Pick a file and press `Enter` — it opens in **the Neovim you are already in**,
not a nested one. This is usually the better door: you keep your buffers, your
LSP, your place.

---

## 1 · The layout

```
┌───────────┬───────────────────┬─────────────────────────┐
│  parent   │  current dir      │  preview                │
│  folder   │  (cursor here)    │  (contents of whatever  │
│           │                   │   the cursor is on)     │
└───────────┴───────────────────┴─────────────────────────┘
```

The preview pane renders syntax-highlighted code, markdown, JSON, images, PDFs
and archive contents. Your `yazi.toml` sets the column ratio to `1:3:4`,
deliberately favouring the preview — you are here to *look* at things.

---

## 2 · Moving around

Same `hjkl` as Neovim, but `h` and `l` mean something different here: they go
**up and down the directory tree**, not left and right.

```
j  k          down / up the file list       (arrow keys work too)
l             enter the directory / open the file
h             go up to the parent directory
g g   /   G   jump to the top / bottom of the list
Ctrl-d / Ctrl-u   half a page down / up
H  /  L       back / forward through your history, like a browser
```

Jumping somewhere far away:

```
Z             jump to a directory by fuzzy-matching your history (zoxide)
z             fuzzy-find a file or directory here (fzf)
g h           go to your home directory
g c           go to ~/.config
```

`Z` is excellent — it knows every directory you have `cd`-ed into, so a few
letters get you anywhere.

### Dotfiles are hidden until you press `.`

Out of the box this config sets `show_hidden = false`, so `.config`, `.git`,
`.dotfiles` and every other dot-name is **invisible** — you cannot see them, and
`l` cannot enter what you cannot put the cursor on.

```
.             show / hide hidden files — toggles, and takes effect instantly
```

That is the whole answer: **press `.` (period), and the dot-entries appear.**
Press it again to hide them. `.` is an unmodified key on every keyboard layout,
Hungarian included.

The toggle lasts as long as the yazi session and is not remembered. To make it
the default instead, edit `yazi/.config/yazi/yazi.toml` in this repo:

```toml
[mgr]
show_hidden = true
```

and restart yazi — no stow re-run needed, the file is already symlinked.

**Which do you want?** Leave it `false` and toggle. In a home directory or a
repo root, hidden entries outnumber the real ones — you would spend most of your
time scrolling past `.cache`, `.local` and `.git` to reach the four files you
came for. `.` costs one keypress on the rare occasion you need them.

Two things that work whether or not hidden files are showing:

- **`g c` jumps straight into `~/.config`**, and `Z` / `z` will land you inside
  any dot-directory by name. Jumping *to* a hidden directory is never blocked —
  only seeing it listed one level up is.
- Once you are **inside** `.config`, its ordinary children are visible as normal.
  The setting hides dot-*entries*, not the contents of a dot-directory.

If `s` or `S` (the recursive searches) come back empty for a file you know is
under a dot-directory, press `.` and search again.

---

## 3 · Looking at things without opening them

This is yazi's real value for you.

```
j  k          just moving the cursor previews each file as you go
J  K          scroll the preview pane down / up (without leaving the list)
Tab           show detailed info about the hovered file
.             show / hide hidden files  (see above — this is how you reach
              anything starting with a dot)
```

`J` and `K` are the important ones. You can read a good chunk of a file — check
whether it is the one you want, skim a config, glance at a log — without ever
opening it. That is the workflow: `j` `j` `j` to find it, `J` to skim it, `Enter`
only if you actually need to edit.

### Markdown is rendered, not shown as source

Land the cursor on any `.md` file and the preview pane shows it **rendered** —
headings styled, tables drawn, code blocks highlighted — via `glow`. No keypress
needed.

This makes yazi a genuinely good read-only markdown browser: `j`/`k` through a
directory of notes, `J`/`K` to scroll whichever one you are on, and you never
open an editor. Press `O` and choose *Read with glow* for a full-screen version.

See [the markdown tutorial](markdown.md) for how it is wired and for the
Neovim side.

---

## 4 · Opening files

```
Enter   or  o     open in Neovim
O                 open with… (pick the program from a menu)
```

From **inside Neovim** (`Space y`), you get extra options:

```
Enter       open in the current window
Ctrl-v      open in a vertical split
Ctrl-x      open in a horizontal split
Ctrl-t      open in a new tab
Tab         cycle through the buffers you already have open
Ctrl-y      copy the file's relative path
Ctrl-q      send the selected files to the quickfix list
F1          show this list — the authoritative version
```

`Ctrl-v` is a good habit: open a second file beside the one you are reading
rather than replacing it.

---

## 5 · Selecting several files

```
Space         toggle selection of the file under the cursor
v             visual mode — move to select a range
Ctrl-a        select everything here
Ctrl-r        invert the selection
Esc           clear the selection
```

Selected files get marked. Every operation below acts on the selection if there
is one, or the hovered file if there is not.

---

## 6 · Actually managing files

```
y             yank (copy)
x             cut
p             paste
P             paste, overwriting anything already there
d             move to trash        ← recoverable
D             delete permanently   ← not recoverable
a             create — a plain name makes a file, ending in / makes a directory
A             create many at once
r             rename
```

Two that are worth knowing about:

- **`A` (bulk create)** and **`r` on a multi-file selection** open the names in
  an editor. You edit them as plain text, save, and yazi applies every change.
  This is by far the fastest way to rename twenty files.
- **`d` trashes, `D` destroys.** Use `d` unless you mean it.

Copying paths — constantly useful when you are about to paste a path into Claude
Code or a terminal:

```
c c       copy the full path
c d       copy the directory path
c f       copy just the filename
c n       copy the filename without its extension
```

---

## 7 · Finding things

```
f           filter — narrows the current list as you type
/           find the next match by name in this directory
n  /  N     next / previous match
s           search by filename, recursively (uses fd)
S           search by file *contents*, recursively (uses ripgrep)
Ctrl-s      cancel a running search
Esc         clear the filter or search
```

The distinction matters: **`f` filters what is in front of you**, while **`s` and
`S` search the whole tree below you**. `S` is a full-text project search that
lands you on the matching files.

---

## 8 · Shell commands and sorting

```
;           run a shell command; the selected files are available as $0, $@
:           same, but wait for it to finish before returning
w           the task manager — watch long copies, see errors
```

Sorting and display:

```
, n         sort naturally (the default: file2 before file10)
, m         sort by modified time      , s   by size      , e   by extension
m s         show size in the side column   (m m mtime, m p permissions, m n none)
```

---

## 9 · Getting out

```
q           quit — and with `y`, your shell lands in the current directory
Q           quit without changing the shell's directory
Esc         cancel a selection, filter or search first
```

If you launched yazi from Neovim with `Space y`, `q` just closes the floating
window.

---

## 10 · Hungarian keyboard notes

yazi needs far fewer awkward characters than Vim does, so there is little to fix.
Two things:

- **Help is `~` (AltGr+1) — press `F1` instead.** Both work, F1 is easier.
- **Tabs use `[` and `]`** (AltGr+F / AltGr+G) for previous/next. Use the number
  keys instead: `t t` makes a tab, then `1`, `2`, `3`… switch between them.

Everything else — `hjkl`, `Space`, `y` `x` `p` `d` `r` `a`, `f` `s` `S`, `z` `Z`
— is a plain unmodified letter.

> yazi's tabs are worth ignoring at first. If you find you want them, tell me and
> I will add home-row aliases in a `keymap.toml`, the same way Neovim got `é`
> and `á`.

---

## 11 · Configuration

Your config is `yazi/.config/yazi/yazi.toml` in this repo, symlinked to
`~/.config/yazi/yazi.toml` by stow. It is deliberately small: sort order, hidden
files off (`show_hidden = false` — [toggle it with `.`](#dotfiles-are-hidden-until-you-press-),
or flip the default there), size in the side column, and the `1:3:4` column
ratio.

Note that the config section is called `[mgr]`. It was renamed from `[manager]`
in yazi 25.5, so older blog posts and Stack Overflow answers will show the old
name and silently fail. If you copy a snippet from the internet and it does
nothing, that is the first thing to check.

The official book is at <https://yazi-rs.github.io> and it is short and good.

---

## 12 · The honest summary

Learn these nine keys and you have 95% of the value:

```
y             launch it (from the shell)
Space y       launch it (from Neovim)
j k h l       move around
J K           skim the preview without opening anything (markdown is rendered)
.             show the dotfiles (they are hidden by default)
Enter         open in Neovim
c c           copy the path
q             quit
F1            what were the other keys?
```

Then leave it alone. Your time is better spent in
[the Neovim tutorial](neovim.md) — that is where reviewing actually
happens.
