-- Yazi as a floating file manager *inside* Neovim, so browsing is a thing you
-- summon and dismiss rather than another app you context-switch to.
--
-- <leader>y  opens yazi with the cursor already on the current file
-- <leader>Y  opens yazi at the project root
-- Inside yazi, <Enter> hands the file back to this Neovim (no nested nvim).
return {
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>y", "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
      { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Yazi (project root)" },
    },
    ---@type YaziConfig
    opts = {
      -- `nvim somedir/` keeps LazyVim's own behaviour; yazi stays opt-in.
      open_for_directories = false,
      floating_window_scaling_factor = 0.9,
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-s>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
      },
    },
  },
}
