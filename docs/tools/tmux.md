# tmux — panes and sessions

Config: `tmux/.config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`

---

## What it's for

Two things, and they are unrelated to each other:

1. **Splitting one terminal window into panes.** Editor in one, a test runner
   in another, a shell in a third — all visible at once.
2. **Sessions that outlive the window.** Close the terminal, reboot the
   terminal emulator, lose the SSH connection — the processes keep running and
   `tmux attach` puts you back exactly where you were.

The second is the one people underrate. A long build or a remote session
survives a dropped connection instead of dying with it.

## Why this one

The alternatives are your terminal emulator's own tabs and splits, or `screen`.

Emulator splits are fine until you want the session to survive the emulator, or
you move between machines and want the same layout. tmux is one config file
that behaves identically over SSH, in WSL, in a VM, and in any emulator.

`screen` does the persistence but not the panes, and its config is worse.

The real cost is a learning curve: every command is a two-step chord. That is
what [the tmux tutorial](../tutorials/tmux.md) is for.

---

## How it's configured

The whole file is about 30 lines. Here is every decision in it.

### The prefix

```tmux
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

Every tmux command is: press the **prefix**, release, then press a key.

**The prefix here is `Ctrl-a`, not the stock `Ctrl-b`.** `Ctrl-a` is reachable
without moving your hand; `Ctrl-b` is not. The cost is real, though:

> Every tmux tutorial on the internet says `Ctrl-b`. **Press `Ctrl-a` wherever
> they do.** That is the only translation you need.

`bind C-a send-prefix` means pressing `Ctrl-a` twice sends a literal `Ctrl-a`
through to the program inside — which matters because `Ctrl-a` is
"jump to start of line" in a shell.

### Mouse

```tmux
set -g mouse on
```

Scroll with the wheel, click a pane to focus it, drag a border to resize.
Purists turn this off; it costs nothing and makes the first week survivable.

### Numbering from 1

```tmux
set -g base-index 1
setw -g pane-base-index 1
```

Windows and panes are numbered from 1 instead of 0, because the number keys are
laid out `1 2 3...` and `prefix 1` should go to the first window rather than
the second.

### Escape time

```tmux
set -sg escape-time 10
```

How long tmux waits after `Esc` to see whether it is the start of an escape
sequence. The default is 500ms, which means **a half-second lag every time you
press `Esc` in Neovim** — which, in a modal editor, is constantly.

10ms is enough for real escape sequences and imperceptible to you. If you use
Neovim inside tmux, this line is not optional.

### Scrollback

```tmux
set -g history-limit 10000
```

10,000 lines per pane instead of the default 2,000. The output you want is
usually the one that just scrolled off.

### Copy mode

```tmux
setw -g mode-keys vi
```

Scrollback navigation uses vi keys — `prefix [` to enter, then `h/j/k/l`,
`/` to search, `v` to select, `y` to copy, `q` to leave. Consistent with
Neovim, so it is one set of keys rather than two.

### Splits that keep the directory

```tmux
bind v split-window -h -c "#{pane_current_path}"
bind | split-window -h -c "#{pane_current_path}"
bind s split-window -v -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```

Two decisions here.

**`-c "#{pane_current_path}"`** is the important one. Stock tmux opens every
new pane in your home directory — so splitting while deep in a project means
`cd`-ing back every single time. This makes a split inherit the current
directory, which is what you meant 100% of the time.

**`v` and `s` as aliases for `|` and `-`.** The mnemonic pair `|` (vertical
line, side-by-side) and `-` (horizontal line, stacked) is the conventional
choice and both still work. But on a Hungarian keyboard `|` is `AltGr+W`, which
makes `prefix |` a three-finger contortion. `v` (vertical split) and `s`
(split) are home-row.

> Note the naming trap, which is tmux's not ours: `-h` produces a
> **side-by-side** split (panes divided by a *horizontal* movement), and `-v`
> produces a **stacked** one. `v` here means "the vertical divider you see", not
> the flag.

### Moving between panes

```tmux
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

vim directions: `prefix h` goes left, `prefix j` down, and so on. Arrow keys
still work by default.

### Reload

```tmux
bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"
```

`prefix r` re-reads the config without killing your session — so you can edit
and test bindings in the session you are editing them from. The `display`
confirms it happened.

### True colour

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
```

The perennial tmux problem: colours look right in the terminal and wrong inside
tmux.

| Line | Does |
|---|---|
| `default-terminal "tmux-256color"` | what tmux claims to be to programs inside it |
| `terminal-overrides ",*256col*:Tc"` | tells tmux the *outer* terminal supports 24-bit colour (`Tc`) |

Without the second line tmux quantises everything to 256 colours, and a theme
built on exact hex values comes out visibly wrong. `-ga` **appends** rather than
replacing, so any existing overrides survive.

### Theme

```tmux
source-file -q ~/.config/theme/tmux-theme.conf
```

Status-bar colours, generated by `scripts/04-theme.sh` from the shared palette.

**`-q` means "quiet: do not error if it is missing"** — so tmux still starts on
a machine where the `theme` package has not been stowed yet. Without it, a
fresh checkout gives you a tmux that refuses to launch, which is a bad first
impression for a cosmetic file.

---

## The bindings, in one table

| Keys | Does |
|---|---|
| `prefix v` or `prefix \|` | split side-by-side, same directory |
| `prefix s` or `prefix -` | split top/bottom, same directory |
| `prefix h/j/k/l` | move between panes |
| `prefix c` | new window |
| `prefix 1/2/3` | go to window 1/2/3 |
| `prefix d` | **detach** — leave it running |
| `prefix [` | copy mode (vi keys, `q` to leave) |
| `prefix r` | reload the config |
| `prefix ?` | list every binding |

From outside: `tmux` starts one, `tmux ls` lists sessions, `tmux attach` goes
back to the last one.

Full walkthrough: **[the tmux tutorial](../tutorials/tmux.md)**.

---

## Related

- [Neovim](neovim.md) — why `escape-time` matters so much
- [the palette](../theme/README.md) — where the status bar colours come from
