-- Markdown: three different ways to look at a document, because they suit
-- different moments.
--
--   Space m r   in-buffer rendering, toggled — headings, tables and code
--               blocks styled in place, source still editable
--   Space m p   side-by-side: source left, glow's render right, refreshed
--               on every save
--   Space m g   full-screen scrollable read via glow's pager
--   Space m b   browser preview, live-updating (the prettiest, least terminal)
--
-- Space u m is LazyVim's own toggle for the in-buffer rendering; Space m r is
-- the same thing, kept under the markdown group so it is findable.

local md = function()
  return require("util.mdpreview")
end

return {
  -- ---------------------------------------------------------------------
  -- In-buffer rendering, made worth looking at
  -- ---------------------------------------------------------------------
  -- LazyVim deliberately strips this plugin back: it blanks the heading icons
  -- (`icons = {}`), disables checkboxes, and leaves tables unstyled. That is
  -- why stock LazyVim markdown looks so plain. This restores the good parts.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Reveal the raw source on the line the cursor is on, so the rendering
      -- never fights you while editing.
      anti_conceal = { enabled = true, above = 0, below = 0 },

      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "block",
        min_width = 40,
        right_pad = 2,
        border = true, -- thin rule above and below
        border_virtual = true,
      },

      code = {
        sign = false,
        width = "block",
        min_width = 45,
        left_pad = 1,
        right_pad = 2,
        border = "thick",
        language_pad = 1,
        language_name = true,
        language_icon = true,
      },

      bullet = { icons = { "●", "○", "◆", "◇" }, right_pad = 1 },

      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },

      quote = { icon = "▋", repeat_linebreak = true },

      pipe_table = { preset = "round", style = "full", alignment_indicator = "━" },

      dash = { icon = "─", width = "full" },
    },
    keys = {
      { "<leader>m", "", desc = "+markdown", ft = "markdown" },
      {
        "<leader>mr",
        function()
          require("render-markdown").buf_toggle()
        end,
        desc = "Toggle in-buffer rendering",
        ft = "markdown",
      },
    },
  },

  -- ---------------------------------------------------------------------
  -- glow: side-by-side and full-screen
  -- ---------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    keys = {
      {
        "<leader>mp",
        function()
          md().toggle()
        end,
        desc = "Preview side-by-side (glow)",
        ft = "markdown",
      },
      {
        "<leader>mg",
        function()
          md().pager()
        end,
        desc = "Read full-screen (glow)",
        ft = "markdown",
      },
    },
  },

  -- ---------------------------------------------------------------------
  -- Browser preview, made to work under WSL
  -- ---------------------------------------------------------------------
  -- markdown-preview.nvim serves the document over localhost and needs a
  -- browser. There is no Linux browser in WSL, so hand the URL to Windows.
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    init = function()
      vim.g.mkdp_echo_preview_url = 1 -- print the URL too, so it is Ctrl-clickable
      vim.g.mkdp_browserfunc = "MkdpOpenInWindows"
      vim.cmd([[
        function! MkdpOpenInWindows(url) abort
          " jobstart, not `!`, so explorer.exe's non-zero exit stays quiet
          call jobstart(['explorer.exe', a:url], {'detach': v:true})
        endfunction
      ]])
    end,
    keys = {
      { "<leader>mb", "<cmd>MarkdownPreviewToggle<cr>", desc = "Preview in browser", ft = "markdown" },
    },
  },
}
