# Shell — zsh, oh-my-zsh, starship

The shell layer is four things stacked: **zsh** (the shell), **oh-my-zsh**
(completions and plugin loading), **starship** (the prompt), and **`.zshrc`**
(everything this setup actually decides).

Config: `zsh/.zshrc` → `~/.zshrc` · `starship/.config/starship.toml` → `~/.config/starship.toml`

---

## zsh

### What it's for

The interactive shell. Not the scripting language — scripts here still say
`#!/usr/bin/env bash`. zsh's job is the thing you type into.

### Why this one

If you are already on zsh, you know the argument. Briefly, versus bash: shared
history that behaves, `**/` recursive globbing, completion that can describe
what it is completing rather than just listing words, and `cd` to a directory
by typing part of its name. None of it is dramatic; all of it removes friction
several hundred times a day.

**Nothing below depends on zsh being your login shell for a trial run.** You
can type `zsh` in a bash session to look around, and only run `chsh` once you
have decided.

---

## oh-my-zsh

### What it's for

A loader. It supplies the `plugins=(...)` mechanism, a large completion
library, and a set of git aliases.

### Why this one

Honestly: because it is the default answer and it works. The alternatives
(zinit, antidote, or hand-rolled `source` lines) are faster to start and
lighter, and if startup time ever became a problem that is the trade to make.
It has not.

**What it costs you:** oh-my-zsh is the single heaviest dependency in this
repo — it is required by `.zshrc` exactly as written. Removing it means
replacing four `plugins=()` entries with four `source` lines, which is a
ten-minute job, not a rewrite.

### How it's configured

```zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
  git                     # git aliases + completions
  zsh-completions         # extra completion definitions
  zsh-autosuggestions     # ghosted suggestions from history
  zsh-syntax-highlighting # colorize commands as you type — KEEP LAST
)
source $ZSH/oh-my-zsh.sh
```

| Setting | What it does | Why |
|---|---|---|
| `ZSH_THEME=""` | oh-my-zsh draws **no** prompt | starship draws the prompt instead. Leave a theme name here and the two fight over the same line |
| `git` | `gst`, `gco`, `gp`… plus git completions | the completions are the real reason; the aliases are optional habit |
| `zsh-completions` | extra completion definitions for tools zsh doesn't ship | pure addition — nothing breaks without it |
| `zsh-autosuggestions` | ghosts the rest of a command from history; `→` accepts | the most divisive one. Some people find the grey text noisy — **comment it out first** if the shell feels busy |
| `zsh-syntax-highlighting` | valid command green, typo red, **as you type** | catches a mistyped command before you press Enter |

**`zsh-syntax-highlighting` must be last in the array.** It works by wrapping
zsh's line-editor hooks, so anything loaded after it is not highlighted. This
is the one ordering constraint in the whole file.

Each plugin is a git clone under `~/.oh-my-zsh/custom/plugins/`. They are not
vendored into this repo — see [installing](../install/README.md).

---

## starship

### What it's for

The prompt: the line telling you where you are, what branch you're on, and
whether the last command failed.

### Why this one

It is a single binary that reads one TOML file, and it detects context
(git state, language versions, exit codes) without you writing shell functions.
Compared to powerlevel10k it is slower to render and less configurable;
compared to a hand-written `PROMPT=` it is far less work. The deciding factor
was that it is *portable* — the same TOML gives the same prompt on any machine
with the binary, with no framework underneath.

### How it's configured

Deliberately almost empty. Starship's defaults are good, and every line added
here is a line to maintain.

```toml
add_newline = true

[cmd_duration]
min_time = 2000
```

| Setting | What it does | Why |
|---|---|---|
| `add_newline = true` | blank line before each prompt | with scrollback full of output, the blank line is what lets your eye find where the last command started |
| `cmd_duration.min_time = 2000` | show elapsed time for commands over 2s | tells you a build took 40s without you having to time it. The threshold keeps it quiet for normal commands |

**The prompt is intentionally near-colourless**, which is why starship is one of
the two tools the palette does *not* theme. The colour budget is spent on `ls`
output, where it carries information; the prompt only needs to be findable.

Want the fuller icon set? `starship preset nerd-font-symbols -o ~/.dotfiles/starship/.config/starship.toml`.

---

## `.zshrc`, line by line

This is where the actual decisions live.

### PATH

```zsh
export PATH="$HOME/.local/bin:$PATH"
```

`~/.local/bin` goes **first**, before the system directories. That is where
`mise` itself lands, and where uv puts the default `python`. First position is
what makes your chosen versions win over the distro's.

At the end of the file:

```zsh
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
```

Go installs `go install`-ed binaries into `$GOPATH/bin`, which nothing else
puts on `PATH`.

### The activation block

Four tools inject shell code at startup. Order matters only for the first one.

```zsh
eval "$(mise activate zsh)"      # runtimes and CLI tools onto PATH
eval "$(starship init zsh)"      # the prompt
eval "$(zoxide init zsh --cmd cd)"  # cd becomes smart cd
source <(fzf --zsh)              # Ctrl-R, Ctrl-T, completion
```

| Line | What it does | If you remove it |
|---|---|---|
| `mise activate` | puts everything mise manages on `PATH` | **most of the rest stops resolving** — this one is load-bearing |
| `starship init` | installs the prompt | you get zsh's default prompt |
| `zoxide init --cmd cd` | replaces `cd` with zoxide's smarter version | `cd` reverts to the builtin. See [Navigation](navigation.md) |
| `fzf --zsh` | binds `Ctrl-R` and `Ctrl-T` | those two key bindings go away |

`mise activate` comes first because the other three are binaries that mise
installed — they are not on `PATH` until it has run.

### Theme

```zsh
source ~/.config/theme/palette.env
source ~/.config/theme/fzf.sh
export BAT_THEME="$THEME_BAT"
```

One palette file feeds bat, delta, fzf, eza, yazi, tmux, lazygit and Neovim.
`BAT_THEME` is read by bat **and** by delta, which follows it. Full story:
**[the palette](../theme/README.md)**.

### Aliases

```zsh
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --level=2 --group-directories-first'
alias lg='eza -l --icons --git --git-repos'

alias cat='bat'
alias md='glow -p'
alias v='nvim'
```

What each flag buys is on the [Navigation](navigation.md) page. The thing worth
knowing here is **why overriding `ls` and `cat` is safe**:

- zsh aliases apply to **interactive shells only**. A `#!/bin/bash` script, a
  `Makefile` recipe, or anything run by another program sees the real `ls`.
- Escape hatches: `\ls` or `command ls` bypasses the alias for one call.

So the blast radius is exactly "what you type", which is the point.

### MANPAGER

```zsh
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

Man pages through bat, syntax-highlighted as `man` language. `col -bx` strips
the backspace-overstrike sequences groff emits for bold — without it you get
`^H` noise. `-p` means plain: no line numbers, no header.

### EDITOR

```zsh
export EDITOR=nvim
export VISUAL=nvim
```

Not decoration — this is what yazi opens files with, what `git commit` opens
for a message, and what any tool that shells out to an editor uses. Set both:
some programs read only one.

### `y` — yazi that changes your directory

```zsh
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
  rm -f -- "$tmp"
}
```

A child process cannot change its parent's directory — so when plain `yazi`
exits, your shell is still where it started. The workaround is the standard
one: yazi writes its final directory to a temp file (`--cwd-file`), and the
function `cd`s the shell there afterwards.

It has to be a **function, not an alias**, because only a function runs `cd` in
your current shell. `yazi` still works on its own; it just leaves you where you
were.

---

## Related

- [Navigation](navigation.md) — what the eza flags and zoxide actually do
- [Runtimes](runtimes.md) — where these binaries come from
- [the palette](../theme/README.md) — the colour machinery `.zshrc` sources
