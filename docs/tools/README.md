# The catalog — what each tool is for, and why it is configured that way

This is the **why/how** half of the repo. The [README](../../README.md) says
*what is here*; these pages say *what it is for, why it was chosen over the
obvious alternative, and what every setting in its config actually does*.

Every page has the same three parts:

1. **What it's for** — the job, in plain terms.
2. **Why this one** — what it replaces, and what you gain. Where the honest
   answer is "taste", it says so.
3. **How it's configured** — the settings, one by one, each with the reason.
   If a line in a config file is not explained on one of these pages, it is a
   bug in the docs.

You can read any page on its own. Nothing here assumes you adopted the whole
repo — most of it is a paragraph and a config file you can copy.

---

## The pages

| Page | Covers |
|---|---|
| **[Shell](shell.md)** | zsh, oh-my-zsh and its four plugins, starship, and every line of `.zshrc` |
| **[Navigation](navigation.md)** | `eza`, `zoxide`, `fzf`, `fd`, `yazi` — finding and moving around |
| **[Reading](reading.md)** | `bat`, `glow`, `ripgrep`, `jq`, `tldr`, `btop` — looking at things |
| **[Git](git.md)** | the `.gitconfig` block by block, `delta`, `lazygit` |
| **[tmux](tmux.md)** | panes and sessions, and every line of `tmux.conf` |
| **[Neovim](neovim.md)** | LazyVim, the LSP set, and the review workflow the whole setup points at |
| **[Runtimes](runtimes.md)** | `mise`, and why the toolchain is not installed from the distro |

Colour is documented separately, because it cuts across every tool:
**[the palette](../theme/README.md)** and **[what `ls` colours mean](../theme/eza-colours.md)**.

Hands-on walkthroughs for the three tools with a learning curve live in
**[tutorials](../tutorials/README.md)**.

---

## Four rules that explain most of the decisions

Read these and most of the config stops looking arbitrary.

### 1 · The familiar command keeps doing the familiar thing

`ls`, `cd` and `cat` still mean what they have always meant. A better program
answers them underneath.

| You type | You get | Why |
|---|---|---|
| `ls` `ll` `la` `lt` | eza | same word, more information |
| `cd` | zoxide | same word, and it remembers where you go |
| `cat` | bat | same word, with syntax colour |
| `md` | glow | **a new word, because it is a new thing** |

That last row is the rule's boundary. `cat` shows you a markdown file's
*source*; `md` shows you the *rendered result*. Two genuinely different
outputs, so they get two different words rather than one word with a flag.

The payoff is that muscle memory keeps working and nothing has to be
un-learned. The cost is that a habit built here does not transfer to a machine
without these aliases — so every alias has an escape hatch: `\ls` or
`command cat` runs the real thing.

### 2 · One palette, every tool

Colour is treated as information, not decoration. A Go file is the same colour
in `ls`, in `cat`, in the yazi preview pane and in Neovim — not because the
themes happen to agree, but because all of them read
`~/.config/theme/palette.env`.

The layer that makes this work is that nothing asks for a *colour*; it asks for
a *role*. `ls` never requests orange, it requests `ROLE_CONFIG`. Repoint the
palette and every meaning survives. See **[the palette](../theme/README.md)**.

### 3 · Every part is a feature flag

Nothing here is load-bearing for anything else, except where a page says so.
Don't want ghosted suggestions? Comment one line out of `plugins=()`. Don't
want delta? Delete two blocks from `.gitconfig`. Each page's *How it's
configured* section says what happens if you remove the thing.

This is deliberate: the setup is meant to be **raided for parts**, not adopted
whole.

### 4 · Config is text and goes in git; binaries never do

No compiled tool is committed here. The repo is a recipe that re-fetches them
(see [Runtimes](runtimes.md)). What *is* committed is the plain text that
decides behaviour, plus the pinned versions that make a rebuild reproducible.

Secrets — ssh keys, tokens, anything in `.env` — stay out entirely.

---

## If you only take three things

For someone who already has a zsh they like and does not want a project:

1. **`eza` + the theme.** The biggest daily gain for the least commitment.
   `ls` starts telling you which files are generated, which are secrets and
   which are yours, at a glance. → [Navigation](navigation.md),
   [what the colours mean](../theme/eza-colours.md)
2. **`zoxide`.** One line in `.zshrc`, and `cd` stops needing paths.
   → [Navigation](navigation.md)
3. **`delta`.** Two blocks in `.gitconfig`, and `git diff` becomes readable.
   → [Git](git.md)

All three are single binaries with no runtime, available in every package
manager. None of them require anything else on this list.
