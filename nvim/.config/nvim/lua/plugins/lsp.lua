-- basedpyright's own default is typeCheckingMode = "recommended", which flags a
-- great deal in ordinary code. "standard" matches what pyright reported, so
-- switching checkers does not come with a wall of new warnings.
--
-- Raise it to "strict" per-project instead, in pyproject.toml:
--     [tool.basedpyright]
--     typeCheckingMode = "strict"
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                  variableTypes = true,
                  callArgumentNames = true,
                  functionReturnTypes = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
