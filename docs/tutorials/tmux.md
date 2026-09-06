# tmux, starting from nothing

tmux gives you **split panes and sessions that survive**. Two ideas; that is the
whole tool.

Why you want it: Claude Code runs in one pane, Neovim in another, a test runner
in a third. You look at all of them at once, and if your terminal window dies,
nothing is lost.

> This describes **your** config, `tmux/.config/tmux/tmux.conf`, not stock tmux.
> The differences are called out where they matter.

---

## 0 · The prefix key

Every tmux command is two steps: press the **prefix**, release, then press the
command key.

**Your prefix is `Ctrl-a`.**

Stock tmux and every tutorial online use `Ctrl-b`. Yours was changed because
`Ctrl-a` is easier to reach. So: **wherever a tutorial says `Ctrl-b`, press
`Ctrl-a`.**

Notation below: `prefix c` means *press Ctrl-a, let go, press c*. Not together.

> `Ctrl-a` is also "go to start of line" in a shell. You lost that. Use
> `prefix Ctrl-a` to send a literal `Ctrl-a` through to the shell, or just
> use `Home`.

---

## 1 · Start here

```bash
tmux                 # start a session
tmux new -s review   # start one with a name
```

You are now inside tmux — note the green status bar at the bottom. Everything
works exactly as before; you just gained a bar and some superpowers.

```
prefix d      detach — leave tmux running, return to your normal shell
tmux ls       list running sessions
tmux a        attach back to the last session
tmux a -t review    attach to a specific one
```

**`prefix d` then `tmux a` is the killer feature.** Your work sits there,
untouched, with processes still running. Close the terminal, reboot WSL's
terminal window, come back — `tmux a` and you are exactly where you left off.

---

## 2 · Panes — splitting the screen

Your config gives you letter keys for this, because the stock bindings are `%`
and `"`, which are Shift-chords on a Hungarian layout.

```
prefix v      split vertically   → two panes side by side   ← use this one
prefix s      split horizontally → one pane above the other
```

Both open in **the same directory** you were in — stock tmux does not do this,
and it is a real annoyance saved.

`prefix |` and `prefix -` do the same thing, if you prefer the conventional
symbols. `|` is AltGr+W on your layout, which is why `v` exists.

### Moving between panes

```
prefix h      left
prefix j      down
prefix k      up
prefix l      right
```

Same `hjkl` directions as Neovim. You can also **just click a pane** — mouse
support is on.

### Managing panes

```
prefix z      ZOOM the current pane to fill the screen — press again to restore
prefix x      close the pane (asks to confirm)
prefix !      break the pane out into its own window
prefix Space  cycle through the preset layouts
```

**`prefix z` is the one you will use most.** Working in a cramped split, zoom to
full screen, do the work, unzoom. Learn this second, after the prefix itself.

Resizing: drag the divider with the mouse. Or hold the prefix and tap arrow keys.

---

## 3 · Windows — like browser tabs

A **window** fills the terminal and holds its own set of panes. The status bar
lists them.

```
prefix c      create a window
prefix n      next window
prefix p      previous window
prefix 1..9   jump straight to a window by number
prefix w      pick from a visual list
prefix ,      rename this window
prefix &      close it (asks to confirm)
```

Your windows are numbered from **1**, not 0, so `prefix 1` is the first one —
matching the number keys' physical order.

---

## 4 · Scrolling and copying

This is the part that trips everyone up, because a terminal's scrollback and
tmux's are different things.

**Scrolling:** just use the mouse wheel. Mouse mode is on, so it works. This
puts you into *copy mode*; press `q` to get back out.

To enter copy mode from the keyboard:

```
prefix [      enter copy mode      ([ is AltGr+F)
```

Once in copy mode, **vi keys work** (your config sets `mode-keys vi`):

```
k  j          up / down a line
Ctrl-u        half a page up
Ctrl-d        half a page down
g  /  G       jump to the top / bottom of the buffer
/text         search backwards through the scrollback
q             leave copy mode
```

**Copying text:**

```
Space         start the selection
h j k l       extend it
Enter         copy it and exit copy mode
prefix ]      paste it   (] is AltGr+G)
```

Or, far simpler: **select with the mouse.** Dragging copies to the tmux buffer
automatically.

> To get text into the **Windows** clipboard (not just tmux's), hold `Shift`
> while selecting with the mouse. That bypasses tmux and lets the terminal
> emulator handle the selection. Then `Ctrl-Shift-V` or right-click pastes it
> back. This is a WSL/terminal thing, not a tmux setting.

Your scrollback holds 10,000 lines — plenty for reviewing a long build log.

---

## 5 · The layout for your workflow

Here is a concrete setup worth building by hand a few times until it is muscle
memory:

```
┌────────────────────────┬───────────────────┐
│                        │                   │
│   Neovim               │   Claude Code     │
│   (reviewing the diff) │                   │
│                        ├───────────────────┤
│                        │   tests / git     │
└────────────────────────┴───────────────────┘
```

```bash
tmux new -s work        # 1. start a named session
# 2. prefix v           →  split into left | right
# 3. prefix l           →  move to the right pane
# 4. prefix s           →  split it top / bottom
# 5. prefix k           →  up to the top-right pane, start claude
# 6. prefix h           →  back to the left pane, run nvim
```

Then in daily use: `prefix z` to zoom whichever pane needs your full attention,
`prefix d` when you stop, `tmux a` when you come back.

If you find yourself building this every morning, that is a sign to write a
small script for it — ask me and I will add one to the repo.

---

## 6 · Config and troubleshooting

```
prefix r      reload the config after you edit it — no restart needed
prefix ?      list every binding currently active
```

`prefix ?` is your reference; it is always accurate for your config, unlike any
document. `q` exits it.

**Colours look wrong or washed out in Neovim** — your conf already sets
`default-terminal "tmux-256color"` plus true-colour overrides, so this should be
fine. If it is not, run `:checkhealth` in Neovim and read the tmux section.

**`Esc` feels laggy in Neovim** — already handled: `escape-time 10`.

**Session cleanup:**

```
tmux kill-session -t work    # end one session
tmux kill-server             # end everything
```

---

## 7 · The seven keys that matter

Ignore the rest until these are automatic:

```
prefix v      split side by side
prefix h/l    move left / right between panes
prefix z      zoom this pane full screen
prefix c      new window
prefix d      detach
tmux a        come back
prefix ?      what were the other keys again?
```

Remember: prefix is **`Ctrl-a`**.
