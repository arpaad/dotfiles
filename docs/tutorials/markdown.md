# Reading and writing markdown

Markdown is the one format where "see the source" and "see the result" are both
legitimately what you want, sometimes within seconds of each other. So this
setup gives you four ways to look at a document, and the useful skill is knowing
which one to reach for.

It spans two tools — Neovim and yazi — which is why this is its own guide rather
than a section in each.

---

## The four ways, and when each is right

| Keys | What you get | Reach for it when |
|---|---|---|
| `Space m r` | **in-buffer rendering** — styled in place, still editable | you are *writing*. The default for markdown files. |
| `Space m p` | **side-by-side** — source left, glow's render right | you are writing something whose layout matters: tables, nested lists |
| `Space m g` | **full-screen** glow, scrollable | you are *reading*. A README, someone's notes. |
| `Space m b` | **browser preview**, live-updating | you want it genuinely pretty, or need to show someone |

All four are under `Space m`. Press `Space m` and wait — the menu lists them.
They only exist in markdown files, so `Space m` does nothing elsewhere.

> Nothing here needs AltGr. `Space` is the leader and `m` is a plain letter.

---

## 1 · In-buffer rendering — `Space m r`

This is `render-markdown.nvim`, and it is on by default for `.md` files. Headings
get icons and a background, code blocks get a border with the language named,
tables are drawn with box-drawing characters, `- [ ]` becomes a real checkbox.

The clever part: **the line your cursor is on shows the raw source.** Move onto a
heading and the `##` reappears so you can edit it; move away and it renders
again. So you are never fighting the display to change something.

```
Space m r      toggle it off and on
Space u m      the same toggle, in LazyVim's UI-toggles menu
```

Turn it off when you need to see exactly what characters are in the file — say
you are debugging why a table will not render.

> **Boxes or blank squares instead of icons?** The Nerd Font is not configured in
> your *terminal's* settings on the Windows side. Everything else here works
> without it; only the icons need it. See the README.

### Why it looked plain before

LazyVim ships this plugin deliberately stripped down — it blanks the heading
icons, disables checkboxes, and leaves tables unstyled. `lua/plugins/markdown.lua`
turns those back on with sensible values. If you ever want it plainer again, that
is the file to edit.

---

## 2 · Side-by-side — `Space m p`

Opens a vertical split with `glow`'s rendered output on the right.

```
Space m p      open it — press again to close
```

Behaviour worth knowing:

- **It re-renders every time you save.** Not on every keystroke — that would
  flicker. Write with `Space w`, and the preview updates.
- **It renders from disk, not from your buffer.** So unsaved changes are not
  shown, and it refuses to open on a file you have never saved.
- **Your cursor stays in the source.** The preview never steals focus.
- **It re-wraps when you resize the split.** glow is told the pane's real width,
  so widening the split reflows the text rather than leaving it wrapped narrow.

The right-hand pane is a terminal buffer, so it scrolls with the mouse. To scroll
it from the keyboard you have to focus it (`Ctrl-w l`), and then it behaves like
any terminal: `Ctrl-\ Ctrl-n` to get out of terminal mode into normal-mode
scrolling, `i` to go back. That is fiddly — which is exactly why `Space m g`
exists for reading.

---

## 3 · Full-screen — `Space m g`

Opens glow's own pager in a floating window. This is the nicest way to *read* a
markdown file in the terminal.

```
Space m g     open
j  k          scroll
d  u          half a page
q             close
```

For reading a long document you did not write, this beats both of the above.

---

## 4 · Browser preview — `Space m b`

`markdown-preview.nvim` serves the document on localhost and opens it in a real
browser, scroll-synced with your cursor and updating live as you type.

```
Space m b     start / stop it
```

WSL has no Linux browser, so this is wired to hand the URL to **Windows**: it
shells out to `explorer.exe`, which opens your Windows default browser. It also
prints the URL in Neovim, so if that fails you can `Ctrl-click` the URL in
Windows Terminal instead.

This is the prettiest option and the least terminal-native. Good for a final
check, or for showing someone something.

---

## 5 · Markdown in yazi

Move the cursor onto any `.md` file in yazi and **the preview pane renders it** —
no keypress. That makes yazi a genuinely good read-only markdown browser: arrow
down a directory of notes and read each one in the right-hand pane.

```
j  k        move between files — each renders as you land on it
J  K        scroll the rendered preview without leaving the file list
Enter       open it in Neovim to edit
O           the opener menu — pick "Read with glow" for a full-screen read
```

`J` / `K` is the pair to remember. You can read a whole document without opening
anything.

### How that is wired

Two pieces, both in `yazi/.config/yazi/`:

- **`package.toml`** pins `piper.yazi`, yazi's official "pipe any command into the
  preview pane" plugin. `ya pkg install` fetches it — `scripts/03-install.sh` does
  this for you on a fresh machine.
- **`yazi.toml`** points `*.md` at `glow`, passing the pane's real width (`$w`) and
  your terminal's light/dark mode (`$t`).

The plugin code itself is not committed — `.gitignore` excludes
`yazi/.config/yazi/plugins/`, and the pinned revision in `package.toml` is the
recipe that re-fetches it. Same principle as `mise` and `lazy-lock.json`.

> If markdown files show as plain text in yazi, `ya pkg install` has not run, or
> `glow` is not on `PATH`. Check with `which glow`.

---

## 6 · glow on its own

`glow` is just a command, so it is useful outside both tools:

```bash
glow README.md          # render to stdout
glow -p README.md       # render in a scrollable pager
glow -w 80 README.md    # wrap at 80 columns
glow https://…/x.md     # render straight from a URL
glow                    # browse markdown files in the current directory
```

`glow -p` is a good habit for reading a README before you decide to open it.

---

## 7 · Where everything lives

| File | What it controls |
|---|---|
| `nvim/.config/nvim/lua/plugins/markdown.lua` | all four modes, and the styling of the in-buffer render |
| `nvim/.config/nvim/lua/util/mdpreview.lua` | the side-by-side glow split (open, refresh-on-save, close) |
| `yazi/.config/yazi/yazi.toml` | the `*.md` → glow previewer, and the `O` opener entry |
| `yazi/.config/yazi/package.toml` | the pinned `piper.yazi` version |
| `mise/.config/mise/config.toml` | `glow` itself |

---

## 8 · The short version

```
Writing markdown       →  just type. Space m r if the rendering gets in the way.
Layout matters         →  Space m p, then save to refresh.
Reading a document     →  Space m g
Reading several        →  yazi:  j k to move, J K to scroll
Showing someone        →  Space m b
```
