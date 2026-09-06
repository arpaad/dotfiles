# Environment Rebuild — Live Status

**Last updated:** 2026-09-06
**Resume:** 🎉 **Rebuild complete.** Session A ✅ and Session B ✅ both done. Only optional loose ends remain (push the repo, delete backups).

Legend: ✅ done · ⏳ pending · ⬜ not started · ⛔ blocked

## Session A — shell + runtimes  ✅ COMPLETE
zsh + oh-my-zsh + starship + mise toolkit; go 1.27.1 / node 24.20.0 / uv 0.12.9; python3 → 3.14.7; old go removed; committed 3c0b640.

## Session B  ✅ COMPLETE

| Item | Status | Notes |
|------|--------|-------|
| tmux (mise) + tmux.conf | ✅ done | tmux 3.7c; stowed; prefix Ctrl-a; test with `tmux` |
| Claude Code → mise node | ✅ done | `which claude` = mise node; v2.1.261; postinstall ran |
| Remove old nvm node 24.16.0 | ✅ done | nvm now 483M (only running 24.20.0 left) |
| Neovim + LazyVim | ✅ done | neovim 0.12.5 via mise; LazyVim stowed; 32 plugins headless-synced; lazy-lock.json committed. Just open `nvim` — LSPs auto-install per language via Mason on first file open. |
| **Retire nvm fully** | ✅ done | 2026-09-06: verified `which claude` on mise node, ran `scripts/09-retire-nvm.sh` (removed `~/.nvm`, ~483 MB), and deleted the 3 `NVM_DIR` lines from `~/.bashrc` (131 → 128 lines; backup at `~/.bashrc.bak-nvm-removal`). node v24.20.0 + Claude 2.1.263 verified working after removal. |

## Remaining optional loose ends
- **Push the repo** (create empty `arpaad/dotfiles` on GitHub + auth first): `git -C ~/dev/dotfiles push -u origin main`
- **Delete backups** when confident: `rm ~/.bashrc.pre-rebuild ~/.gitconfig.pre-rebuild ~/.bashrc.bak-nvm-removal`
- **Move docs into the repo:** `~/env.plan.md`, `~/env.state.md`, `~/NEXT-SESSION.md` → `~/dev/dotfiles/docs/`

## Handy
- Reset zoxide DB: `rm ~/.local/share/zoxide/db.zo`
- Toggle a zsh plugin: comment its line in `plugins=(...)` in `zsh/.zshrc`
- tmux prefix: Ctrl-a  (split: `Ctrl-a |` / `Ctrl-a -`, reload: `Ctrl-a r`)
- Rollback shell: `chsh -s /usr/bin/bash`

## Notes
- Backups still present: ~/.bashrc.pre-rebuild, ~/.gitconfig.pre-rebuild, ~/.bashrc.bak-nvm-removal (delete when confident).
- Home cleanup done: freed ~5.9 GB (go modcache, old go tarball, .dotnet, .safety).
- The `system` node v18.19.1 nvm used to report is a separate OS-level node — untouched by the nvm removal.
- Node is now 100% mise-managed; nothing on PATH references `~/.nvm`.
