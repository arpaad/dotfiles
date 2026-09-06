-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ---------------------------------------------------------------------------
-- Python: which type checker
-- ---------------------------------------------------------------------------
-- LazyVim defaults to `pyright`. basedpyright is a fork that fixes pyright's
-- main annoyances — inlay hints, better inference, no telemetry, fully open
-- source — and is a drop-in replacement. Its own default strictness
-- ("recommended") is noisy, so lua/plugins/lsp.lua pins it to "standard",
-- which matches what pyright would have reported.
--
-- `ty`, Astral's checker (the uv / ruff people), is the interesting one to
-- watch: same Rust-fast approach, and it will likely win. As of writing it is
-- 0.0.78 — a preview, with incomplete diagnostics coverage, so not yet the
-- thing you want vetting code for you.
--
-- Switching when it matures is genuinely just this line:
--
--     vim.g.lazyvim_python_lsp = "ty"
--
-- Everything else follows automatically: LazyVim disables pyright and
-- basedpyright, keeps ruff for linting and formatting, and Mason installs the
-- `ty` binary on the next start (it is in Mason's registry, so no mise entry is
-- needed). The basedpyright block in lua/plugins/lsp.lua simply goes inert —
-- harmless to leave in place for an easy switch back.
--
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
