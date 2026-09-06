-- Reviewing code is a git operation, so this is the centre of the setup.
--
-- LazyVim already ships gitsigns (hunk signs in the gutter, ]h / [h to jump,
-- <leader>gh* to stage/reset/preview) and <leader>gg for lazygit. What is
-- missing is a *whole-change* review view — that is diffview.

-- Which branch to diff a feature branch against. Prefers what the remote calls
-- its default branch, then falls back to local main/master.
local function base_branch()
  local out = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    return (out[1]:gsub("^origin/", ""))
  end
  for _, b in ipairs({ "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", b })
    if vim.v.shell_error == 0 then
      return b
    end
  end
  return "HEAD"
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
    opts = {
      enhanced_diff_hl = true, -- richer intra-line highlighting
      view = {
        -- Side-by-side is what you want for reading someone else's code.
        default = { layout = "diff2_horizontal" },
        -- 3-way view when resolving a merge conflict.
        merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
        file_history = { layout = "diff2_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 32 },
      },
      -- `q` closes the whole thing from anywhere. Diffview does not bind this
      -- by default and its absence is the #1 way to feel trapped.
      keymaps = {
        view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
        file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
        file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
      },
    },
    keys = {
      { "<leader>gv", "", desc = "+diffview" },
      { "<leader>gvv", "<cmd>DiffviewOpen<cr>", desc = "Review uncommitted changes" },
      {
        "<leader>gvb",
        function()
          vim.cmd("DiffviewOpen " .. base_branch() .. "...HEAD")
        end,
        desc = "Review whole branch (vs base)",
      },
      { "<leader>gvl", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Review last commit" },
      { "<leader>gvs", "<cmd>DiffviewOpen --cached<cr>", desc = "Review staged only" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "History of this file" },
      { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "History of repo" },
      { "<leader>gvf", "<Esc><cmd>'<,'>DiffviewFileHistory --follow<cr>", desc = "History of selection", mode = "v" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
      { "<leader>gvt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
    },
  },
}
