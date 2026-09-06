-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ---------------------------------------------------------------------------
-- Hungarian keyboard: bracket motions without AltGr
-- ---------------------------------------------------------------------------
-- Vim uses [ and ] as prefixes for almost all "jump to next/previous thing"
-- motions: ]h next hunk, ]d next diagnostic, ]q next quickfix item, ]b next
-- buffer, ]] next function... On a Hungarian layout those need AltGr+F and
-- AltGr+G, which is hopeless for a key you press hundreds of times an hour.
--
-- é and á sit on the home row (exactly where ; and ' are on a US layout) and
-- Vim binds nothing to them, so they are free real estate:
--
--     á h   ==  ]h   (next hunk)          é h  ==  [h   (previous hunk)
--     á d   ==  ]d   (next diagnostic)    é d  ==  [d
--     á q   ==  ]q   (next quickfix)      é q  ==  [q
--
-- The real [ and ] keep working, so every tutorial and :help page still
-- applies — you just have a faster way to type them.
--
-- ő and ú are the same trick for { and } (paragraph / block jumps), which
-- would otherwise be AltGr+B and AltGr+N.
local hu_aliases = {
  ["é"] = "[",
  ["á"] = "]",
  ["ő"] = "{",
  ["ú"] = "}",
}

for lhs, rhs in pairs(hu_aliases) do
  -- remap = true is what makes `á h` resolve through to gitsigns' ]h mapping.
  vim.keymap.set({ "n", "x", "o" }, lhs, rhs, { remap = true, desc = rhs .. " (Hungarian alias)" })
end
