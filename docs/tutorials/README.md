# Tutorials

Four hands-on walkthroughs, written for someone coming from VSCode who has
never used a modal editor or a multiplexer.

These are **not** generic guides adapted from the internet. Every key, every
binding and every behaviour described is what *this* config actually does — so
you can follow along without translating anything.

| Guide | Covers | Worth it if |
|---|---|---|
| **[Neovim](neovim.md)** | modes, motions, LSP, and the diff-review workflow the whole setup is built around | you want the editor. Budget a week of being slower before it pays back |
| **[tmux](tmux.md)** | panes, windows, and sessions that survive a closed terminal | you have ever lost work to a closed window or a dropped SSH connection |
| **[yazi](yazi.md)** | the file manager — **and an honest account of where it does and doesn't help** | you explore unfamiliar repositories, or do bulk file operations |
| **[markdown](markdown.md)** | four ways to view a markdown file, across Neovim and yazi | you write or read docs in the terminal |

Read each in order the first time. After that, the tables are lookup
references.

---

## Which to read first

**tmux**, if you read only one. It is the smallest curve — two ideas and about
six keys — and the payoff (a session that survives a closed terminal) is
immediate and requires no habit change.

**Neovim** is the biggest investment and the biggest return, but it is the one
that genuinely costs you a week. Do not start it in a week you are busy.

**yazi** and **markdown** are short, and can be read whenever the need comes
up.

---

## Reference, not tutorial

If you want to know *why* something is configured the way it is rather than how
to use it, that lives in the catalog:

- [Neovim config](../tools/neovim.md) · [tmux config](../tools/tmux.md) · [yazi config](../tools/navigation.md#yazi--the-file-manager)
- [What `ls` colours mean](../theme/eza-colours.md) — the one reference worth
  reading cover to cover; it makes every directory listing readable
