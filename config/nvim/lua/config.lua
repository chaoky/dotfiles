local function switchOrCreateTab(tabNum)
  local status = pcall(vim.api.nvim_tabpage_get_number, tabNum)
  if status == false then vim.api.nvim_command "tabnew" end
  vim.api.nvim_set_current_tabpage(tabNum)
end

---@type LazySpec
return {
  {
    "https://github.com/direnv/direnv.vim",
    config = function() vim.g.direnv_silent_load = 1 end,
  },

  { "wakatime/vim-wakatime" },

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
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },

  {
    "ahmedkhalf/project.nvim",
    main = "project_nvim",
    opts = {
      show_hidden = true,
      silent_chdir = true,
      detection_methods = { "pattern" },
      patterns = { ".git", "Cargo.toml", "package.json", ".envrc", "moon.yml", "neovim.yml" },
      scope_chdir = "tab",
    },
  },

  -- scope buffers to tab
  {
    "tiagovla/scope.nvim",
    opts = {},
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
    dependencies = { { "linrongbin16/lsp-progress.nvim", opts = {} } },
    opts = function(_, opts)
      local LspProgress = {
        provider = require("lsp-progress").progress,
        update = {
          "User",
          pattern = "LspProgressStatusUpdated",
          callback = vim.schedule_wrap(function() vim.cmd "redrawstatus" end),
        },
      }
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
        LspProgress,
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        { hl = { fg = "pink" }, provider = tabnum },
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

  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      features = {
        autoformat = true,
        codelens = true,
        inlay_hints = true,
        semantic_tokens = true,
      },
      formatting = {
        disabled = {
          "lua_ls",
        },
      },
      servers = {
        "relay_lsp",
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
            ["<C-t>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle Term" },
          },
          n = {
            ["<leader>fp"] = {
              function() require("telescope").extensions.projects.projects {} end,
              desc = "Project",
            },
            ["<leader>f~"] = {
              function() require("telescope").extensions.file_browser.file_browser { cwd = "~", hidden = true } end,
              desc = "File in home",
            },
            ["<leader>fd"] = {
              function() require("telescope").extensions.file_browser.file_browser { cwd = "%:p:h", hidden = true } end,
              desc = "File in dir",
            },
            ["<leader>fg"] = {
              function() require("telescope.builtin").git_files {} end,
              desc = "Files git",
            },
            ["<leader><leader>"] = {
              function() require("telescope.builtin").find_files {} end,
              desc = "Search files",
            },
            ["<leader>tt"] = { "<cmd>terminal<cr>", desc = "In buffer" },
            ["<A-1>"] = { function() switchOrCreateTab(1) end },
            ["<A-2>"] = { function() switchOrCreateTab(2) end },
            ["<A-3>"] = { function() switchOrCreateTab(3) end },
            ["<A-4>"] = { function() switchOrCreateTab(4) end },
            ["<A-5>"] = { function() switchOrCreateTab(5) end },
            ["<leader>O"] = { "<C-W>c", desc = "Close window" },
            ["<leader>o"] = { "<C-W>W", desc = "Other window" },
            ["<leader>b"] = {
              function() require("telescope.builtin").buffers { ignore_current_buffer = true } end,
              desc = "Buffers",
            },
            k = { vim.lsp.buf.hover, desc = "Lsp Hover" },
            m = { "<cmd>b#<cr>", desc = "previous buffer" },
          },
          t = {
            ["<Esc>"] = { "<C-\\><C-n>" },
            ["<Del>"] = { "<Esc>" },
          },
        },
      },
    },
  },
}