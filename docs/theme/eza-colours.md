# Reading `ls` output — what eza's colours mean

`ls`, `ll`, `la` and `lt` are all `eza`, themed by
`eza/.config/eza/theme.yml`. The colours are not decoration; each one is a claim
about the file. This is the legend.

The colours come from **one shared palette** — `~/.config/theme/palette.env` —
which also themes bat, delta, fzf, yazi, tmux, lazygit and Neovim. So `ls` and
`cat` agree with each other about what colour a Go file is, by construction
rather than by coincidence. See **[the palette](README.md)** for that machinery.

Crucially, nothing below names a colour. Every entry names a **role**
(`ROLE_CONFIG`, `ROLE_DANGER`, …) and the palette decides what a role looks
like — which is what lets the whole toolset be re-themed without any of the
meanings below changing.

---

## The four signals

Colour answers *what is this*. The three text attributes answer *what should I do
about it*. They are independent and combine freely.

| Signal | Means | Example |
|---|---|---|
| **hue** | what role the thing plays | yellow = source code |
| **bold** | **you can act on it** — enter it, run it, it is an entry point | `src/`, `deploy.sh`, `Makefile` |
| **dim** | **you can ignore it** — generated, locked, cached, vendored | `go.sum`, `node_modules/`, `*.pyc` |
| **underline** | **something is wrong or unsafe** | broken symlink, merge conflict, world-writable |
| *italic* | it points elsewhere — it is not the thing itself | any symlink |

The discipline that makes this work is restraint. Bold is *only* for things you
can act on, so a bold entry always means something. Underline appears perhaps
twice a month, which is exactly why you notice it.

---

## Hues

| Role | Currently | Means | Typical |
|---|---|---|---|
| `ROLE_DIR` *(bold)* | blue | a place you can go | directories |
| `ROLE_LINK` *(italic)* | pale ice | a pointer, not the thing | symlinks |
| `ROLE_MOUNT` *(bold)* | deep teal | another filesystem | mount points |
| `ROLE_RUN` | green | **it runs** | executables, `*.sh` `*.bash` `*.zsh` |
| `ROLE_CODE` | yellow | **code you write** | `.go` `.py` `.ts` `.js` `.lua` `.rs` … |
| `ROLE_CONFIG` | orange | **configuration** — decides how something behaves | `.toml` `.yaml` `.json` `.ini` `.tf`, `Makefile`, `Dockerfile` |
| `ROLE_DATA` | cyan | **data** — content, not code and not config | `.csv` `.tsv` `.sql` `.db` `.parquet` |
| `ROLE_PROSE` | light purple | **prose to read** | `.md` `.txt` `.rst` `.pdf` `.docx` |
| `ROLE_ARCHIVE` | teal | a sealed container | `.tar.gz` `.zip` `.7z` … |
| `ROLE_MEDIA` | pink | images, video, audio | `.png` `.mp4` `.mp3` |
| `ROLE_DANGER` | red | **secrets** | `.pem` `.key` `.crt` |
| `ROLE_ALARM` | hot magenta | **the loudest thing available** | `.env`, world-writable, setuid, conflicts |
| `ROLE_IGNORE` *(dim)* | grey | machine-owned; do not read, do not edit | lockfiles, `*.pyc`, `dist/`, `.venv/` |
| `ROLE_PLAIN` | foreground | an ordinary file with nothing to say about it | `big.bin`, `data.out` |
| `ROLE_MUTED` / `ROLE_FAINT` | dim greys | present but uninformative; structure and absence | permission dashes, separators |

The *Currently* column is the only part of this table that a re-theme changes.

### The two loudest things

Both are deliberately the most visually aggressive entries in a listing:

- **`.env`, `.netrc`** — `ROLE_ALARM`, bold **and** underlined. These hold
  credentials and live in the open. Nothing else gets all three.
- **a broken symlink** — red, bold, underlined, and the arrow and target are
  underlined too, so you see immediately *what* is missing.

---

## The columns in `ll`

### Permissions — `.rwxr-xr-x`

The principle is **escalate only what earns attention**:

| Bit | Colour | Why |
|---|---|---|
| `r` | quiet grey | almost everything is readable — it carries no information |
| `w` | yellow | a real capability: this can be changed |
| `x` | green | a real capability: this can be run |
| `-` | dark grey | absence, pushed into the background |
| `w` in the **other** column | **`ROLE_ALARM` + underline** | world-writable: anyone on the box can edit it |
| setuid / setgid | **`ROLE_ALARM` + underline** | runs as someone else — the classic privilege-escalation hole |

So a normal file is mostly grey with a little yellow, and the two genuine hazards
are the only alarm-coloured things you will ever see there.

### Size — brightness tracks disk usage

faint (bytes) → muted (KB) → **`ROLE_CODE` (MB)** → **`ROLE_CONFIG` (GB)** → **`ROLE_ALARM` (huge)**

Scanning a directory for what is eating space becomes a matter of looking for the
brightest number rather than reading any of them.

### User and group

| Colour | Means |
|---|---|
| plain | you |
| dim grey | someone else — not your problem |
| **bold `ROLE_DANGER`** | `root` — privileged, and not you |

### Git status

Deliberately the same colour language as a diff, so `ll` and `Space g v v` in
Neovim tell you the same story:

| Colour | State |
|---|---|
| `ROLE_ADDED` | new |
| `ROLE_CHANGED` | modified |
| `ROLE_REMOVED` | deleted |
| `ROLE_MOVED` | renamed |
| `ROLE_CONFIG` | type changed |
| dim | ignored |
| **`ROLE_ALARM` + bold + underline** | **conflicted** — deal with this now |

---

## Precedence: which rule wins

Most specific wins. From weakest to strongest:

```
filekinds   (is it a dir? a symlink? executable?)
   ↓
file_type   (eza's own categories: source, document, image, …)
   ↓
extensions  (.toml, .csv, .pem, …)
   ↓
filenames   (exact: Makefile, .env, go.sum, node_modules)
```

This is why `node_modules/` is dim grey rather than bold blue: it is a directory,
but the exact-name rule outranks that, and "ignore me" is the more useful fact.
It is also why `pnpm-lock.yaml` is dim instead of config-peach.

**Symlinks are the one exception worth knowing.** The link's own name is
`ROLE_LINK` italic, but eza colours the **target** by what the target actually is:

```
good.lnk -> app.go
^^^^^^^^    ^^^^^^
ROLE_LINK   ROLE_CODE — it is a Go file, and eza says so
italic
```

The `->` arrow is dim, because it is punctuation and should not compete.

---

## Two things that will bite you if you edit the theme

0. **Do not edit `eza/.config/eza/theme.yml` — it is generated.** Edit
   `scripts/templates/eza-theme.yml.in` (structure) or
   `~/.config/theme/palette.env` (colour), then run `scripts/04-theme.sh`.

1. **eza silently ignores keys it does not recognise.** A typo is not an error —
   it simply has no effect. If a change appears to do nothing, suspect the key
   name before suspecting the colour.

2. **eza merges your file over its own defaults**, so attributes you did not ask
   for survive. Setting only `foreground` on source files left them *bold*,
   because eza's default for source is bold — which quietly destroyed the whole
   "bold means actionable" idea. That is why `is_bold: false` appears explicitly
   throughout the theme. If a signal starts meaning nothing, this is why.

After running `scripts/04-theme.sh`, just run `ls`. No reload, no restart.

---

## Related: how the other tools divide up the same job

The naming follows one rule — **the familiar command keeps doing the familiar
thing, and the better tool takes over quietly underneath**:

| You type | You get | Why |
|---|---|---|
| `ls` / `ll` / `la` / `lt` | eza, themed as above | same word, more information |
| `cd` | zoxide — learns your directories | same word, remembers |
| `cdi` | zoxide **i**nteractive, via fzf | the `i` is the fuzzy picker |
| `cat` | bat — the **source**, syntax-highlighted | same word, colour |
| `md` | glow — markdown **rendered** | a different word, because it is a different thing |

That last pair is the distinction worth internalising: for a markdown file,
**`cat` shows you the source and `md` shows you the result.** `cat notes.md`
gives you `## Heading` in colour; `md notes.md` gives you a styled heading. bat
never renders, glow never shows source — so the two commands never overlap, and
you pick by which one you actually want to see.

In Neovim the same split exists as `Space m r` (render in place) versus turning
it off — see [the markdown tutorial](../tutorials/markdown.md).
