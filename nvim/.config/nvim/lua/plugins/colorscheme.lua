-- The colorscheme name lives in ~/.config/theme/palette.env, the same file that
-- feeds bat, eza, fzf, delta, tmux and lazygit — so there is one place to change
-- the look of everything.
--
-- LazyVim already bundles tokyonight (this is its default) and catppuccin, so no
-- plugin spec is needed for either. Point THEME_NVIM at anything else and add
-- its plugin here.
local function theme()
  local fallback = "tokyonight-moon"
  local fh = io.open(vim.fn.expand("~/.config/theme/palette.env"), "r")
  if not fh then
    return fallback
  end
  local name
  for line in fh:lines() do
    name = line:match('^THEME_NVIM="([^"]+)"') or line:match("^THEME_NVIM=(%S+)")
    if name then
      break
    end
  end
  fh:close()
  return name or fallback
end

return {
  { "LazyVim/LazyVim", opts = { colorscheme = theme() } },
}
