return {
  recommended = {
    ft = { "purescript" },
    root = { "spago.yaml" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "purescript" } },
  },

  {
    "neovim/nvim-lspconfig",

    ---@class PluginLspOpts
    opts = {

      ---@type lspconfig.options
      servers = {
        purescriptls = {
          settings = {
            purescript = {
              addSpagoSources = true,
              flags = { debounce_text_changes = 150 },
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        purescript = { "purs-tidy" },
      },
    },
  },
}
