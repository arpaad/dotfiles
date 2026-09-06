-- Extra parsers on top of LazyVim's defaults. `opts_extend` is declared on
-- LazyVim's treesitter spec, so this list is appended, not substituted.
--
-- Makefiles have no language server (there isn't a good one), but a parser
-- still buys correct syntax highlighting, indent and folds.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "make",
        "gitcommit",
        "gitignore",
        "git_rebase",
        "gitattributes",
        "dockerfile",
        "sql",
      },
    },
  },
}
