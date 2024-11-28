-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Bunch of settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 2
vim.opt.foldlevel = 99999999 -- for ufo

-- Sync clipboard
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Switch to nomal mode" })

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

vim.filetype.add({
  extension = {
    kk = "koka",
  },
})

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "akinsho/toggleterm.nvim", lazy = false, version = "*", config = true },
    { "kdheepak/lazygit.nvim", lazy = true, cmd = { "LazyGit" } },
    { "kawre/leetcode.nvim", build = ":TSUpdate html", dependencies = { "nvim-telescope/telescope.nvim" }, opts = {} },
    { "wakatime/vim-wakatime" },
    { "JoosepAlviste/nvim-ts-context-commentstring" }, -- Use comment string from TS
    { "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically
    { "direnv/direnv.vim", config = function() vim.g.direnv_silent_load = 1 end },
    { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" }, opts = {} }, -- folds,

    -- UI Plugins --
    { "Bekaboo/dropbar.nvim" }, -- cool breadcrumbs thing
    { -- cool notifications and cmdline
      "folke/noice.nvim",
      opts = {},
      dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    },
    { "navarasu/onedark.nvim", config = function() require("onedark").load() end }, -- cool theme
    { "lewis6991/gitsigns.nvim", opts = {} }, -- git utils
    {
      "ahmedkhalf/project.nvim",
      config = function()
        require("project_nvim").setup({})
        require("telescope").load_extension("projects")
      end,
    },

    { -- cool modeline
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons", "folke/noice.nvim" },
      opts = function()
        return {
          sections = {
            lualine_x = {
              {
                require("noice").api.statusline.mode.get,
                cond = require("noice").api.statusline.mode.has,
                color = { fg = "#ff9e64" },
              },
            },
          },
        }
      end,
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      opts = {
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
        },
        buffers = {
          follow_current_file = { enabled = true },
        },
      },
    },

    {
      "folke/which-key.nvim",
      opts = function()
        local tb = require("telescope.builtin")
        local te = require("telescope").extensions
        local fbrowser = te.file_browser.file_browser

        local function call(func, args_)
          return function()
            local args = args_ or {}
            if args.cwd == "git" then
              local file_dir = vim.fn.expand("%:h")
              local cmd = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = file_dir })
              local cwd = cmd:wait().stdout:gsub("\n", "", 1)
              args.cwd = cwd
            end

            local defaults = {}
            if args.hidden == true then
              defaults.no_ignore = true
              defaults.additional_args = function() return { "--no-ignore" } end
            end

            local merge = vim.tbl_extend("force", defaults, args)
            return func(merge)
          end
        end

        local function format() require("conform").format({ async = true, lsp_format = "fallback" }) end

        return {
          spec = {
            { "<leader>d", desc = "Document" },
            { "<leader>df", format, desc = "Format" },
            { "<leader>de", "<cmd>Telescope diagnostics<CR>", desc = "Errors" },
            { "<leader>dg", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Grep" },
            { "<leader>dd", require("dropbar.api").pick, desc = "Dropbar" },
            { "<leader>dr", vim.lsp.buf.rename, desc = "Rename" },
            { "<leader>da", vim.lsp.buf.code_action, desc = "Action" },

            { "<leader>p", desc = "Project" },
            { "<leader>pp", te.projects.projects, desc = "Projects" },
            { "<leader>pg", tb.live_grep, desc = "Grep" },
            { "<leader>pG", call(tb.live_grep, { hidden = true }), desc = "Grep" },
            { "<leader>pf", tb.find_files, desc = "Files" },
            { "<leader>pF", call(tb.find_files, { hidden = true }), desc = "Files" },

            { "<leader>g", desc = "Git" },
            { "<leader>gi", "<cmd>LazyGit<cr>", desc = "LazyGit" },
            { "<leader>gf", call(tb.find_files, { cwd = "git" }), desc = "Files" },
            { "<leader>gF", call(tb.find_files, { cwd = "git", hidden = true }), desc = "Files" },
            { "<leader>gg", call(tb.live_grep, { cwd = "git" }), desc = "Grep" },
            { "<leader>gG", call(tb.live_grep, { cwd = "git", hidden = true }), desc = "Grep" },

            { "<leader>m", desc = "Manage" },
            { "<leader>mu", "<cmd>Lazy update<cr>", desc = "Update" },
            { "<leader>me", "<cmd>Neotree toggle<cr>", desc = "Toggle Tree" },
            { "<leader>mh", "<cmd>Telescope help_tags<cr>", desc = "Help" },

            { "<leader>f", call(tb.find_files, { cwd = "%:h" }), desc = "Files" },
            { "<leader>F", call(tb.find_files, { cwd = "%:h", hidden = true }), desc = "Files" },

            { "<leader>e", call(fbrowser, { cwd = "%:h" }), desc = "Explore" },
            { "<leader>E", call(fbrowser, { cwd = "%:h", hidden = true }), desc = "Explore" },

            { "<leader>o", "<cmd>Telescope frecency<CR>", desc = "Old" },
            { "<leader><leader>", function() tb.buffers({ ignore_current_buffer = true }) end, desc = "Buffers" },
            { "<leader>n", "<cmd>Noice dismiss<cr>", desc = "Notification dismiss" },
            { "<leader>k", "<cmd>bdelete<cr>", desc = "Kill Buffer" },

            { "<C-p>", "<cmd>Telescope neoclip<CR>", desc = "Neoclip" },

            { "gd", tb.lsp_definitions, desc = "Definition" },
            { "gr", tb.lsp_references, desc = "References" },
            { "gI", tb.lsp_implementations, desc = "Implementation" },
            { "gD", vim.lsp.buf.declaration, desc = "Declaration" },
            { "U", "<cmd>Telescope undo<cr>", desc = "Undo History" },

            {
              "<C-t>",
              '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>',
              mode = { "n", "t" },
              desc = "Toggle Term",
            },
          },
        }
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      event = "VimEnter",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-telescope/telescope-frecency.nvim",
        "debugloop/telescope-undo.nvim",
      },
      config = function()
        local telescope = require("telescope")
        telescope.load_extension("ui-select")
        telescope.load_extension("file_browser")
        telescope.load_extension("frecency")
        telescope.load_extension("undo")

        local function select_n(i)
          return function(b)
            local actions = require("telescope.actions.set")
            actions.shift_selection(b, -i)
            actions.select(b, "default")
          end
        end

        require("telescope").setup({
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown(),
            },
          },
          defaults = {
            mappings = {
              i = {
                ["11"] = select_n(0),
                ["22"] = select_n(1),
                ["33"] = select_n(2),
                ["44"] = select_n(3),
                ["55"] = select_n(4),
              },
            },
          },
        })
      end,
    },

    { -- clipobar history
      "AckslD/nvim-neoclip.lua",
      dependencies = { "nvim-telescope/telescope.nvim" },
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

    -- Languages --
    {
      "neovim/nvim-lspconfig",
      config = function()
        -- require("lspconfig").relay_lsp.setup({})
        require("lspconfig").koka.setup({})
        require("lspconfig").rust_analyzer.setup({
          init_options = {
            ["rust_analyzer"] = {
              cargo = {
                targetDir = true,
              },
            },
          },
        })
        -- require("lspconfig").vtsls.setup({})
        require("lspconfig").ts_ls.setup({})
        require("lspconfig").lua_ls.setup({})
        require("lspconfig").jsonls.setup({})
      end,
    },

    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      opts = {
        notify_on_error = false,
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettierd", "prettier", "biome", stop_after_first = true },
        },
      },
    },

    {
      "nvim-treesitter/nvim-treesitter",
      opts = function()
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

    { -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      "folke/lazydev.nvim",
      ft = "lua",
      dependencies = { "Bilal2453/luvit-meta" },
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },

    { -- Autocompletion --
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path" },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          completion = { completeopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete({}),
          }),
          sources = {
            { name = "lazydev", group_index = 0 },
            { name = "nvim_lsp" },
            { name = "path" },
          },
        })
      end,
    },
  },

  install = { colorscheme = { "onedark" } },
  checker = { enabled = true },
})
