local function switchOrCreateTab(tabNum)
  local status = pcall(vim.cmd.tabn, tabNum)
  if status then return end

  local last_tab = vim.fn.tabpagenr "$"
  for _ = last_tab, tabNum - 1 do
    vim.cmd.tabnew {}
  end

  vim.cmd.tabn(tabNum)
end

-- require("lspconfig").koka.setup {}

vim.filetype.add {
  extension = {
    kk = "koka",
  },
}

---@type LazySpec
return {
  {
    "https://github.com/direnv/direnv.vim",
    config = function() vim.g.direnv_silent_load = 1 end,
  },

  { "wakatime/vim-wakatime" },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window.mappings.t = "copy_to_clipboard"
      opts.window.mappings.T = "copy_selector"
      opts.window.mappings.y = ""
      opts.window.mappings.Y = ""
    end,
  },

  {
    "folke/which-key.nvim",
    init = function()
      local presets = require "which-key.plugins.presets"
      presets.operators["y"] = nil
      presets.operators["yy"] = nil
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts) opts.defaults.file_ignore_patterns = { ".git/" } end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  -- clipobar history
  {
    "AckslD/nvim-neoclip.lua",
    event = { "User AstroFile", "InsertEnter" },
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("neoclip").setup {
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
      }
      require("telescope").load_extension "neoclip"
    end,
  },

  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local function tabnum() return "%3(" .. vim.fn.tabpagenr() .. "%)" end
      local status = require "astroui.status"
      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        { hl = { fg = "pink" }, provider = tabnum, update = "TabEnter" },
        status.component.nav(),
      }

      opts.winbar = {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        {
          status.component.separated_path {
            path_func = status.provider.filename { modify = ":.:h" },
          },
          status.component.file_info {
            file_icon = false,
            filename = {},
            filetype = false,
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbar", true),
            surround = false,
            update = "BufEnter",
          },
          status.component.breadcrumbs {
            icon = { hl = true },
            hl = status.hl.get_attributes("winbar", true),
            prefix = true,
            padding = { left = 0 },
          },
        },
      }
    end,
  },

  -- {
  --   "dense-analysis/ale",
  --   config = function()
  --     local g = vim.g
  --     g.ale_fix_on_save = 1
  --     g.ale_fixers = { "biome" }
  --     g.ale_linters = { ["*"] = { "biome" } }
  --   end,
  -- },

  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(self, opts)
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.koka = {
        install_info = {
          url = "https://github.com/mtoohey31/tree-sitter-koka",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "koka",
      }
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = false,
  },

  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      features = {
        autoformat = false,
        codelens = true,
        inlay_hints = true,
        semantic_tokens = true,
      },
      servers = {
        "relay_lsp",
        "koka",
      },
      ---@diagnostic disable: missing-fields
      config = {
        rust_analyzer = {
          init_options = {
            ["rust_analyzer"] = {
              cargo = {
                targetDir = true,
              },
            },
          },
        },
      },
    },

    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        options = {
          opt = {
            showtabline = 0,
            swapfile = false,
            timeoutlen = 0,
            mouse = {},
          },
        },
        mappings = {
          [{ "n", "v", "s", "o" }] = {
            n = { "b" },
            e = { "h" },
            i = { "l" },
            o = { "w" },
            l = { "^" },
            u = { "k" },
            U = { "{" },
            y = { "j" },
            Y = { "}" },
            [";"] = { "$" },
            D = { "s" },
            s = { "i" },
            S = { "I" },
            w = { "u" },
            W = { "<C-r>" },
            t = { "y" },
            tt = { "yy" },
            T = { "yiw" },
          },
          [{ "n", "t" }] = {
            ["<C-t>"] = { '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>', desc = "Toggle Term" },
          },
          n = {
            ["<leader>fd"] = {
              function() require("telescope").extensions.file_browser.file_browser { cwd = "%:p:h", hidden = true } end,
              desc = "File in dir",
            },
            ["<leader>fg"] = {
              function() require("telescope.builtin").git_files { hidden = true } end,
              desc = "Files git",
            },
            ["<leader><leader>"] = {
              function() require("telescope.builtin").find_files { hidden = true } end,
              desc = "Search files",
            },
            ["<leader>tt"] = { "<cmd>terminal<cr>", desc = "In buffer" },
            ["<A-1>"] = { function() switchOrCreateTab(1) end },
            ["<A-2>"] = { function() switchOrCreateTab(2) end },
            ["<A-3>"] = { function() switchOrCreateTab(3) end },
            ["<A-4>"] = { function() switchOrCreateTab(4) end },
            ["<A-5>"] = { function() switchOrCreateTab(5) end },
            ["<leader>b"] = {
              function() require("telescope.builtin").buffers { ignore_current_buffer = true } end,
              desc = "Buffers",
            },
            k = { vim.lsp.buf.hover, desc = "Lsp Hover" },
            m = { "<cmd>b#<cr>", desc = "previous buffer" },
          },
          [{ "t" }] = {
            ["<C-e>"] = { "<C-\\><C-n>" },
          },
        },
      },
    },
  },
}
