local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      opts = { colorscheme = "catppuccin" },
      import = "lazyvim.plugins",
    },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },

    -- direnv
    { "https://github.com/direnv/direnv.vim" },

    -- wakatime
    { "wakatime/vim-wakatime" },

    -- terminal
    {
      "akinsho/toggleterm.nvim",
      config = {
        open_mapping = "<C-t>",
      },
    },

    -- Project
    {
      "jay-babu/project.nvim",
      main = "project_nvim",
      opts = {
        show_hidden = true,
        silent_chdir = true,
        detection_methods = { "pattern" },
        patterns = { ".git/", "Cargo.toml", "package.json" },
      },
    },

    -- NN for escape
    {
      "TheBlob42/houdini.nvim",
      lazy = false,
      opts = {
        mappings = { "ii" },
        timeout = 300,
      },
      keys = {
        { "ii", "<Esc>", mode = "i" },
        { "ii", "<C-\\><C-n>", mode = "t" },
      },
    },

    -- bottom line
    {
      "nvim-lualine/lualine.nvim",
      dependencies = {
        { "linrongbin16/lsp-progress.nvim", opts = {} },
      },
      opts = function(_, opts)
        opts.options = {
          component_separators = "|",
          section_separators = "",
        }
        local function num()
          return vim.fn.tabpagenr()
        end
        table.insert(opts.sections.lualine_x, 1, require("lsp-progress").progress)
        opts.sections.lualine_z = { num }
      end,
    },

    -- clipobar history
    {
      "AckslD/nvim-neoclip.lua",
      event = { "User AstroFile", "InsertEnter" },
      dependencies = {
        { "nvim-telescope/telescope.nvim" },
      },
      config = function()
        require("neoclip").setup({
          keys = {
            on_paste = {
              set_reg = true,
            },
            telescope = {
              i = {
                paste = "<cr>",
              },
            },
          },
        })
        require("telescope").load_extension("neoclip")
      end,
    },

    -- scope buffers to tab
    {
      "tiagovla/scope.nvim",
      opts = {},
    },

    -- more lsp
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          relay_lsp = {},
        },
        setup = {
          relay_lsp = function(_, opts)
            opts.auto_start_compiler = true
          end,
        },
      },
    },

    -- disabled
    { "akinsho/bufferline.nvim", enabled = false, keys = false },
    {
      "folke/which-key.nvim",
      opts = {
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = false, -- default bindings on <c-w>
          nav = false, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
        triggers_blacklist = {
          i = { "i" },
          v = { "i" },
        },
      },
    },
    {
      "folke/noice.nvim",
      opts = {
        lsp = {
          progress = {
            enabled = false,
          },
        },
      },
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax", "catppuccin" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
