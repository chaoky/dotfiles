return {
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },
  {
    -- Add the community repository of plugin specifications
    "AstroNvim/astrocommunity",
    -- example of importing a plugin, comment out to use it or add your own
    -- available plugins can be found at https://github.com/AstroNvim/astrocommunity

    -- { import = "astrocommunity.colorscheme.catppuccin" },
    -- { import = "astrocommunity.completion.copilot-lua-cmp" },
    { import = "astrocommunity.project.project-nvim" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.typescript" },
    { import = "astrocommunity.pack.lua" },
  },
  {
    "folke/which-key.nvim",
    init = function()
      local presets = require "which-key.plugins.presets"
      presets.operators["y"] = nil
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts) opts.defaults.file_ignore_patterns = { ".git/" } end,
  },
  {
    "ahmedkhalf/project.nvim",
    opts = function(_, opts)
      opts.show_hidden = true
      opts.ignore_lsp = { "null-ls", "jsonls" }
      opts.silent_chdir = true
    end,
  },
}
