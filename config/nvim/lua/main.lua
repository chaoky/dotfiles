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
vim.opt.foldlevel = 99999999 -- For UFO
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.showtabline = 0

pcall(vim.fn.serverstart, "/tmp/nvim.single")

vim.keymap.set("n", "<C-e>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
vim.keymap.set({ "t", "i", "v", "x" }, "<C-e>", "<C-\\><C-n>", { desc = "Switch to nomal mode" })

vim.filetype.add({
	extension = {
		kk = "koka",
		purs = "purescript",
	},
})

local fargs = require("keys").fargs
local fstate = require("keys").fstate

require("lazy").setup({
	spec = {
		require("keys").keys,
		{ "akinsho/toggleterm.nvim", lazy = false, version = "*", config = true },
		{ "brianhuster/unnest.nvim", lazy = false, priority = 1001 },
		{ "kdheepak/lazygit.nvim", lazy = true, cmd = { "LazyGit" } },
		{
			"kawre/leetcode.nvim",
			build = ":TSUpdate html",
			dependencies = { "nvim-telescope/telescope.nvim" },
			opts = {
				lang = "rust",
				injector = {
					["rust"] = {
						before = { "fn main(){}", "struct Solution;" },
					},
				},
			},
		},
		{ "wakatime/vim-wakatime" },
		{ "JoosepAlviste/nvim-ts-context-commentstring" }, -- Use comment string from TS
		{ "tpope/vim-sleuth" }, -- Detect tabstop and shift width automatically
		{ "lewis6991/gitsigns.nvim", opts = {} }, -- Git utilities
		{
			"direnv/direnv.vim",
			config = function()
				vim.g.direnv_silent_load = 1
			end,
		},

		{ -- Folds
			"kevinhwang91/nvim-ufo",
			dependencies = { "kevinhwang91/promise-async" },
			opts = {
				provider_selector = function()
					return { "treesitter", "indent" }
				end,
			},
		},

		{ -- Cool breadcrumbs thing
			"Bekaboo/dropbar.nvim",
			opts = {
				bar = {
					enable = function(buf, win, _)
						return vim.wo[win].winbar == "" and vim.fn.win_gettype(win) == "" and vim.bo[buf].ft ~= "help"
					end,
				},
			},
		},

		{ -- Cool mode line
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons", "folke/noice.nvim" },
			opts = function()
				return {
					options = {
						section_separators = "",
						component_separators = "|",
					},
					sections = {
						lualine_c = {},
						lualine_x = {
							{
								require("noice").api.status.mode.get,
								cond = require("noice").api.status.mode.has,
								color = { fg = "#ff9e64" },
							},
						},
					},
				}
			end,
		},

		{ -- Cool notifications and cmd line
			"folke/noice.nvim",
			opts = {},
			dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		},

		{ -- Cool theme
			"navarasu/onedark.nvim",
			config = function()
				require("onedark").load()
			end,
		},

		{ -- Find projects
			"ahmedkhalf/project.nvim",
			config = function()
				require("project_nvim").setup({})
				require("telescope").load_extension("projects")
			end,
		},

		{ -- Fuzzy finder
			"nvim-telescope/telescope.nvim",
			event = "VimEnter",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"nvim-telescope/telescope-ui-select.nvim",
				"nvim-telescope/telescope-file-browser.nvim",
				"nvim-telescope/telescope-frecency.nvim",
				"debugloop/telescope-undo.nvim",
				"BurntSushi/ripgrep",
			},
			config = function()
				local tb = require("telescope.builtin")
				local tas = require("telescope.actions.state")
				local t = require("telescope")
				local fbrowser = t.extensions.file_browser.file_browser
				local fb_utils = require("telescope._extensions.file_browser.utils")

				local function select_n(i)
					return function(b)
						local actions = require("telescope.actions.set")
						actions.shift_selection(b, -i)
						actions.select(b, "default")
					end
				end

				local function finderPath(promptn)
					return tas.get_current_picker(promptn).finder.path
				end

				local function mapAbs(x)
					return vim.tbl_map(function(path)
						return path:absolute()
					end, x)
				end

				t.setup({
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown(),
						},
						["file_browser"] = {
							mappings = {
								i = {
									["<C-f>"] = function(promptn)
										fargs(tb.find_files, {
											cwd = finderPath(promptn),
											default_text = tas.get_current_line(),
										})
									end,
									["<C-g>"] = function(promptn)
										local selections = fb_utils.get_selected_files(promptn, false)
										fargs(tb.live_grep, {
											-- stylua: ignore
											search_dirs = vim.tbl_isempty(selections)
												and { finderPath(promptn) }
												or mapAbs(selections),
										})
									end,
									["<C-e>"] = false,
								},
							},
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
							n = {
								["<C-e>"] = "close",
							},
						},
					},
					pickers = {
						find_files = {
							mappings = {
								i = {
									["<C-h>"] = function()
										fargs(tb.find_files, {
											cwd = fstate.path,
											all = not fstate.all,
											default_text = tas.get_current_line(),
										})
									end,
									["<C-i>"] = function()
										fargs(fbrowser, { cwd = fstate.path })
									end,
								},
							},
						},
						live_grep = {
							mappings = {
								i = {
									["<C-h>"] = function()
										fargs(tb.live_grep, {
											cwd = fstate.path,
											all = not fstate.all,
											default_text = tas.get_current_line(),
										})
									end,
									["<C-i>"] = function()
										fargs(fbrowser, { cwd = fstate.path })
									end,
								},
							},
						},
					},
				})

				t.load_extension("ui-select")
				t.load_extension("file_browser")
				t.load_extension("frecency")
				t.load_extension("undo")
			end,
		},

		{ -- Clipboard history
			"gbprod/yanky.nvim",
			opts = { highlight = { timer = 200 } },
		},

		{ -- Lsp configs
			"neovim/nvim-lspconfig",
			config = function()
				require("lspconfig").koka.setup({})
				require("lspconfig").nixd.setup({})
				require("lspconfig").lua_ls.setup({})
				require("lspconfig").purescriptls.setup({
					settings = {
						purescript = {
							addSpagoSources = true,
						},
					},
					flags = {
						debounce_text_changes = 150,
					},
				})
				require("lspconfig").rust_analyzer.setup({
					init_options = {
						["rust_analyzer"] = {
							cargo = {
								targetDir = true,
							},
						},
					},
				})

				require("lspconfig").vtsls.setup({})
				-- require("lspconfig").ts_ls.setup({})
				-- require("lspconfig").deno.setup({})
				-- require("lspconfig").relay_lsp.setup({})

				require("lspconfig").jsonls.setup({})
				require("lspconfig").eslint.setup({})
				require("lspconfig").yamlls.setup({})
				require("lspconfig").terraformls.setup({})
				-- require("lspconfig").harper_ls.setup({})
				require("lspconfig").dockerls.setup({})
				require("lspconfig").unison.setup({})
			end,
		},

		{ -- Auto format
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
			-- Unison
			"unisonweb/unison",
			branch = "trunk",
			config = function(plugin)
				vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
				require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
			end,
			init = function(plugin)
				require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
			end,
		},

		{ -- Tree-sitter configs
			"nvim-treesitter/nvim-treesitter",
			config = function()
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

				require("nvim-treesitter.configs").setup({
					auto_install = true,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end,
		},

		{ -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
			-- used for completion, annotations and signatures of Neovim API
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

		{ -- Auto completion
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				{
					"L3MON4D3/LuaSnip",
					build = "make install_jsregexp",
					dependencies = {
						{
							"rafamadriz/friendly-snippets",
							config = function()
								require("luasnip.loaders.from_vscode").lazy_load()
							end,
						},
					},
				},
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-path",
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				luasnip.config.setup({})

				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					completion = { completeopt = "menu,menuone,noinsert" },
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete({}),
						["<C-n>"] = cmp.mapping.scroll_docs(4),
						["<C-p>"] = cmp.mapping.scroll_docs(-4),
						["<Tab>"] = cmp.mapping.select_next_item(),
						["<S-Tab>"] = cmp.mapping.select_prev_item(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = {
						{ name = "lazydev", group_index = 0 },
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "path" },
					},
				})

				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities =
					vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			end,
		},
	},

	install = { colorscheme = { "onedark" } },
	checker = { enabled = true },
})
