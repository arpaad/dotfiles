# Neovim, starting from VSCode

You know `:wq`. That is genuinely enough to begin. This walks you from there to
reviewing a whole branch of code without leaving the terminal.

Read it in order the first time. After that, use the tables as a lookup.

> **Everything here is what *your* config actually does.** It is LazyVim plus the
> extras listed in `nvim/.config/nvim/lazyvim.json` and the four files in
> `nvim/.config/nvim/lua/`. Nothing below is generic advice you have to adapt.

---

## 0 · The one idea that makes Vim make sense

VSCode has one mode: you type, letters appear. Vim has **modes**, and the one
you live in is *not* the typing one.

| Mode | You are… | How you got there | How you leave |
|---|---|---|---|
| **Normal** | *navigating and commanding.* Letters are commands, not text. | where you start; `Esc` from anywhere | — |
| **Insert** | typing text, like VSCode | `i` | `Esc` |
| **Visual** | selecting text | `v` (chars), `V` (lines) | `Esc` |
| **Command** | typing a `:` command | `:` | `Enter` or `Esc` |

**Normal mode is home.** Return to it constantly with `Esc`. If Neovim ever
seems to be ignoring you or beeping, you are in the wrong mode — press `Esc`
twice and you are safe.

Since your job is mostly *reading* code, you will spend ~90% of your time in
Normal mode. That is the mode Vim is actually good at, which is why this pairing
suits you.

### Lost? The panic button

```
Esc Esc      back to Normal mode
:q!          quit, throw away changes
:qa!         quit everything, throw away changes
u            undo (press repeatedly)
Ctrl-r       redo
```

---

## 1 · The Hungarian keyboard problem, and what I did about it

Vim was designed on a US keyboard. Two of its most-used keys, `[` and `]`, are
**AltGr+F** and **AltGr+G** on a Hungarian layout. They prefix nearly every
"jump to the next/previous thing" motion, so you would be doing an AltGr chord
hundreds of times an hour.

So `lua/config/keymaps.lua` adds home-row aliases. `é` and `á` sit exactly where
`;` and `'` are on a US board, and Vim binds nothing to them:

| Press | Means | Because `[`/`]` would be |
|---|---|---|
| `é` | `[` | AltGr+F |
| `á` | `]` | AltGr+G |
| `ő` | `{` | AltGr+B |
| `ú` | `}` | AltGr+N |

They are **prefixes**, so they compose with everything:

```
á h    next git hunk          é h    previous git hunk
á d    next diagnostic        é d    previous diagnostic
á q    next quickfix item     é q    previous quickfix item
á b    next buffer            é b    previous buffer
á ]    next function          é [    previous function
```

The real `[` and `]` still work. So when you read a tutorial or a `:help` page
that says `]c`, you can press either `AltGr+G c` or `á c`. **Nothing you learn
elsewhere is invalidated** — you just have a faster way to type it.

### Other characters you will need in code

Unavoidable, and worth memorising early:

| Char | Hungarian keys | Char | Hungarian keys |
|---|---|---|---|
| `[` `]` | AltGr+F / AltGr+G | `{` `}` | AltGr+B / AltGr+N |
| `\|` | AltGr+W | `\` | AltGr+Q |
| `@` | AltGr+V | `$` | AltGr+É |
| `#` | AltGr+X | `&` | AltGr+C |
| `~` | AltGr+1 | `^` | AltGr+3 |

> If any of these differ on your machine, trust your keyboard over this table —
> layouts vary slightly by OS. The Neovim aliases above are what matter, and
> those are fixed by your config, not by the OS.

Two more things about your layout worth knowing:

- Hungarian is **QWERTZ**: `y` and `z` are swapped versus QWERTY. In Vim, `y` is
  *yank* (copy) and `z` is folding/scrolling. The keys send what their label
  says, so `y` copies — it is just in a different physical spot than in every
  screencast you will watch.
- **`Space` is your Leader key.** It is a plain, unmodified key, identical on
  every layout. This is why almost every custom command below starts with
  `Space` — it is the one thing a Hungarian layout makes *easier*.

---

## 2 · The single most useful habit: press Space and wait

Press `Space` in Normal mode and **stop**. A menu appears at the bottom showing
every key you could press next, with descriptions. Press another key, and it
narrows.

```
Space      → the whole menu
Space g    → the git submenu
Space g v  → the diffview submenu
```

This is `which-key`, and it means **you do not have to memorise this document**.
You can discover the entire config by pressing Space and reading. If you learn
one thing today, learn this.

`Esc` backs out of the menu.

---

## 3 · Moving around

### Inside a file

```
h j k l        left, down, up, right   (arrow keys also work — use them at first)
w  /  b        forward / back one word
0  /  $        start / end of line          ($ is AltGr+É)
gg /  G        top / bottom of file
Ctrl-d / Ctrl-u   half a screen down / up   ← your main reading motion
{  /  }        previous / next blank-line block   →  ő  /  ú
%              jump to the matching bracket
```

**For review specifically**, these three matter most:

```
Ctrl-d  Ctrl-u    scroll while keeping the cursor centred
zz                redraw with the current line in the middle of the screen
Ctrl-o  Ctrl-i    jump backward / forward through your jump history
```

`Ctrl-o` is the equivalent of VSCode's "go back". You will use it constantly
after jumping to a definition.

### Between files

```
Space Space     find file by name (fuzzy)        ← your Ctrl-P
Space /         search text in the whole project ← your Ctrl-Shift-F
Space ,         switch between open buffers
Space e         file tree sidebar
Space f r       recently opened files
```

A **buffer** is just "a file Neovim has open". `Space ,` is your tab bar.

```
Space b d       close this buffer
á b   /  é b    next / previous buffer
```

### Splits

```
Space -         split horizontally (one above the other)
Ctrl-w h/j/k/l  move between splits
Ctrl-w =        make splits equal size
Ctrl-w o        close every split except this one
```

---

## 4 · Reading code: syntax, LSP, and symbols

Your config enables language servers for **Go, Python, TypeScript/JavaScript,
JSON, Markdown, TOML and YAML**. Python uses `basedpyright` (a better-behaved
pyright fork) alongside `ruff`. Treesitter also gives correct highlighting and
folding for **Makefiles**, git commits, Dockerfiles and SQL — Makefiles have no
usable language server, so highlighting is all you get there, which is fine.

The first time you open a `.go` or `.py` file, Mason downloads its server in the
background. Watch the bottom-right for progress; give it a few seconds.

### The commands you will use every day

| Keys | Does | VSCode equivalent |
|---|---|---|
| `g d` | go to definition | F12 |
| `g r` | find all references | Shift+F12 |
| `g I` | go to implementation | — |
| `K` | show docs / type in a popup | hover |
| `Ctrl-o` | jump back where you came from | Alt+← |
| `Space c a` | code actions (fixes, refactors) | Ctrl+. |
| `Space c r` | rename symbol everywhere | F2 |
| `Space s s` | jump to a symbol in this file | Ctrl+Shift+O |
| `Space s S` | jump to a symbol in the project | Ctrl+T |

Press `K` twice to move the cursor *into* the popup so you can scroll it; `q`
closes it.

### Diagnostics (errors and warnings)

```
á d   /  é d      next / previous diagnostic
Space c d         show the full message for the one under the cursor
Space x x         list every diagnostic in the file
Space x X         list every diagnostic in the project
```

`Space x x` opens a **quickfix list** — a clickable list at the bottom. `Enter`
jumps to an entry, `á q` / `é q` steps through them without leaving your file.
This is the fastest way to sweep a file Claude just wrote.

### Sticky function header

You enabled `treesitter-context`. When you scroll into the middle of a long
function, its signature **pins itself to the top line of the window** so you
always know what you are inside. This is the single biggest quality-of-life win
for reading unfamiliar code.

```
Space u t       toggle it off/on
```

### Folding

Collapse code you have already reviewed:

```
z a       toggle the fold under the cursor
z R       open every fold
z M       close every fold
```

(Remember: on your layout `z` is where a US board has `y`.)

---

## 5 · Reviewing changes — the part you actually care about

This is the workflow. Two tools, used at different zoom levels.

### Zoom level 1 — gitsigns, in the file you are reading

You get no extra windows: changes are marked in the left gutter of any file in a
git repo. `│` is a change, `▁` a deletion.

```
á h   /  é h        jump to next / previous changed hunk
Space g h p         preview the hunk inline (see the old lines right there)
Space g h b         who wrote this line, and why (full commit message)
Space g h d         diff this file against the index, side by side
```

Reviewing hunk-by-hunk and accepting as you go:

```
Space g h s         stage this hunk        ← "I approve this bit"
Space g h r         reset this hunk        ← "undo this bit"
Space g h u         un-stage the last hunk you staged
```

There is also a hunk **text object**, `i h`. So `d i h` deletes the whole hunk
the cursor is in, and `v i h` selects it. This is a precise way to throw away one
specific change.

### Zoom level 2 — diffview, for a whole change

`diffview.nvim` is the piece that makes this setup a review environment rather
than an editor. Everything lives under `Space g v` (**v** for *view*):

| Keys | Opens |
|---|---|
| `Space g v v` | **all uncommitted changes** ← your everyday one |
| `Space g v b` | **the whole branch** vs `main`/`master` ← for a finished feature |
| `Space g v l` | just the last commit |
| `Space g v s` | only what is staged |
| `Space g v f` | the full history of the current file |
| `Space g v F` | the full history of the repo |
| `Space g v c` | close diffview |

`Space g v b` figures out your base branch automatically (it asks git what the
remote's default branch is, then falls back to `main`, then `master`).

**Inside diffview:**

```
Tab  /  Shift-Tab    next / previous changed file
j  k                 move in the file list on the left
Enter  or  o         open the selected file's diff
Space g v t          hide/show the file list (more room for the diff)
q                    close the whole thing
```

Once you are in a diff, the left window is the old version and the right is the
new. Ordinary Vim movement works in both, and they scroll together. To step
through the actual changes:

```
á c   /  é c         next / previous change   (]c and [c, Vim's built-in diff motions)
```

You can **edit the right-hand side directly** while reviewing. That is the whole
point for you: read the diff, spot the bug, fix it in place, keep going.

Staging from the file panel, so a review produces a commit:

```
-        stage / unstage the file under the cursor
S        stage everything
X        discard the changes in this file   ← destructive, no undo via u
```

### Zoom level 3 — lazygit, for committing

```
Space g g       open lazygit, full screen
```

Inside lazygit: `Tab` cycles panels, `Space` stages the selected file, `c`
commits, `P` pushes, `q` quits. `?` lists every key. It is a separate program
with its own keys — treat `?` as the manual.

### The whole loop, end to end

```
1.  Space g v v        see everything Claude changed
2.  Tab                walk to the first changed file
3.  read the diff; á c to hop between changes
4.  spot a problem → fix it in the right-hand window
5.  á d                check nothing is now broken (diagnostics)
6.  -                  stage the file: approved
7.  Tab                next file, back to 3
8.  q  then  Space g g commit in lazygit
```

---

## 6 · Editing, the minimum viable set

You said "basic editing", so here is exactly that. The pattern is
**verb + object**: `d` (delete) + `w` (word) = `dw`.

```
Verbs:   d delete    c change (delete + insert)    y yank (copy)    v select
Objects: w word   $ to end of line   i w inner word   i ( inside parens
         i " inside quotes   i p paragraph   i h inner git hunk
```

Which composes:

```
c i w      replace the word under the cursor          ← use this constantly
c i "      replace what is inside the quotes
d d        delete the whole line
y y        copy the whole line
p  /  P    paste after / before
d i h      delete a whole git hunk
```

Entering Insert mode with intent:

```
i    before the cursor          a    after the cursor
I    start of the line          A    end of the line       ← very common
o    open a new line below      O    a new line above
```

Undo and redo:

```
u        undo
Ctrl-r   redo
```

Search and replace:

```
/thing        search forward     (n next, N previous)
*             search for the word under the cursor
:%s/old/new/g            replace in the whole file
:%s/old/new/gc           …asking for confirmation on each   ← safer
```

Saving:

```
Space w      save            ← easier than :w
:wq          save and quit   ← the one you already knew
Space q q    quit everything
```

Your config **formats on save** via the language servers and formatters Mason
installed, so you generally do not need to think about style.

---

## 7 · Yazi from inside Neovim

```
Space y      open yazi, cursor already on the current file
Space Y      open yazi at the project root
```

It appears as a floating window. Pick a file, press `Enter`, and it opens in
*this* Neovim — no nested editor. Full details in
[the yazi tutorial](yazi.md).

Use `Space e` (the sidebar) for navigating the project you are in, and
`Space y` when you want to browse, preview, or move files around.

---

## 7b · Markdown

Markdown files get four different views, all under `Space m`:

```
Space m r      toggle the in-buffer rendering (on by default)
Space m p      side-by-side: source left, rendered right, refreshed on save
Space m g      read it full-screen, scrollable
Space m b      open a live preview in your Windows browser
```

The in-buffer rendering shows the **raw source on the line your cursor is on**,
so it never gets in the way of editing.

Full details, including how markdown works in yazi:
[the markdown tutorial](markdown.md).

---

## 8 · When something breaks

```
:checkhealth        diagnose everything; read the ERROR lines
:Lazy               plugin manager. Press U to update, then restart
:LazyExtras         browse/enable language support. x toggles a row
:Mason              language servers. i installs, X uninstalls
:LspInfo            which server is attached to this file, if any
:messages           the log of notifications you missed
```

**"No LSP for this file"** — open `:Mason` and check the server installed. Go
needs `gopls`, Python `basedpyright` + `ruff`, TS/JS `vtsls`, Markdown
`marksman`.

**"My config change did nothing"** — Neovim reads config at startup. Restart it.

**Boxes instead of icons** — the Nerd Font is not set in your *terminal's*
settings, on the Windows side. See the README.

---

## 9 · Your first week

Do not try to absorb this. Do this instead:

- **Day 1** — `Esc`, `i`, `:wq`, `Space Space` to open files, arrow keys to move.
  Nothing else. Genuinely.
- **Day 2** — `h j k l` instead of arrows. `w` `b` `gg` `G` `Ctrl-d`.
- **Day 3** — `Space g v v` and `Tab`. Start reviewing. Read only; no edits.
- **Day 4** — `g d`, `Ctrl-o`, `K`. Now you can explore code properly.
- **Day 5** — `d d`, `c i w`, `u`. Start fixing what you find.
- **Week 2** — `á h`, `Space g h s`, `Space g h p`. The hunk workflow.

Anything you forget: press `Space` and wait. There is also `:Tutor`, Vim's own
30-minute interactive lesson, which is genuinely good.
