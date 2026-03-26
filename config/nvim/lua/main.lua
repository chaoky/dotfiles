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
vim.opt.foldlevel = 99 -- Start with all folds open (for nvim-ufo)
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
	name = "xsel",
	copy = {
		["+"] = "xsel --clipboard --input",
		["*"] = "xsel --primary --input",
	},
	paste = {
		["+"] = "xsel --clipboard --output",
		["*"] = "xsel --primary --output",
	},
	cache_enabled = 0,
}
vim.opt.showtabline = 0

-- Augroup for all custom autocmds (prevents accumulation on reload)
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- LSP attach handler for buffer-local setup
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
	end,
})

local fargs = require("keys").fargs
local fstate = require("keys").fstate

require("lazy").setup({
	spec = {
		-- Use parent nvim when launched from subshell
		{ "brianhuster/unnest.nvim", lazy = false, priority = 1001 },
		{ "kdheepak/lazygit.nvim", lazy = true, cmd = { "LazyGit" } },
		{ "wakatime/vim-wakatime" },
		{ "akinsho/toggleterm.nvim", lazy = false, version = "*", config = true },
		-- Detect tabstop and shift width automatically
		{ "tpope/vim-sleuth" },
		-- Git utilities
		{ "lewis6991/gitsigns.nvim", opts = {} },
		-- Clipboard history
		{ "gbprod/yanky.nvim", opts = { highlight = { timer = 200 } } },
		-- notifications and cmd line
		{ "folke/noice.nvim", opts = {}, dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" } },

		{
			"folke/snacks.nvim",
			lazy = false,
			opts = {
				lazygit = { enabled = true },
				bufdelete = { enabled = true },
			},
		},

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
				menu = {
					keymaps = {
						["o"] = function()
							local menu = require("dropbar.utils").menu.get_current()
							if not menu then
								return
							end
							local cursor = vim.api.nvim_win_get_cursor(menu.win)
							local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
							if not component then
								return
							end
							local root_menu = menu:root()
							if root_menu then
								root_menu:close(false)
							end
							component:jump()
						end,
					},
				},
				bar = {
					enable = function(buf, win, _)
						return vim.wo[win].winbar == "" and vim.fn.win_gettype(win) == "" and vim.bo[buf].ft ~= "help"
					end,
				},
				sources = {
					path = {
						relative_to = function(_, _)
							return vim.fn.expand("%:p:h:h")
						end,
					},
					treesitter = {
						valid_types = {
							"class",
							"constructor",
							"enum",
							"enum_member",
							"function",
							"interface",
							"macro",
							"method",
							"namespace",
							"rule",
							"section",
							"struct",
							"field",
							"property",
							"constant",
							"type",
						},
					},
					lsp = {
						valid_symbols = {
							"File",
							"Module",
							"Namespace",
							"Class",
							"Method",
							"Constructor",
							"Enum",
							"Interface",
							"Function",
							"Struct",
							"Field",
							"Property",
							"Constant",
							"TypeParameter",
						},
					},
				},
			},
		},

		{ -- mode line
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

		{ -- File explorer
			"A7Lavinraj/fyler.nvim",
			dependencies = { "echasnovski/mini.icons" },
			branch = "stable",
			lazy = false,
			opts = {
				views = {
					finder = {
						mappings = {
							["<C-f>"] = function(self)
								local entry = self:cursor_node_entry()
								local dir = entry and entry.path or vim.fn.getcwd()
								if vim.fn.isdirectory(dir) == 0 then
									dir = vim.fn.fnamemodify(dir, ":h")
								end
								require("fyler").close()
								require("telescope.builtin").find_files({ cwd = dir })
							end,
							["<C-g>"] = function(self)
								local entry = self:cursor_node_entry()
								local dir = entry and entry.path or vim.fn.getcwd()
								if vim.fn.isdirectory(dir) == 0 then
									dir = vim.fn.fnamemodify(dir, ":h")
								end
								require("fyler").close()
								require("telescope.builtin").live_grep({ cwd = dir })
							end,
						},
					},
				},
			},
		},

		{ -- Fuzzy finder
			"nvim-telescope/telescope.nvim",
			event = "VimEnter",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"nvim-telescope/telescope-ui-select.nvim",
				"nvim-telescope/telescope-frecency.nvim",
				"debugloop/telescope-undo.nvim",
				"BurntSushi/ripgrep",
			},
			config = function()
				local tb = require("telescope.builtin")
				local tas = require("telescope.actions.state")
				local t = require("telescope")

				local function select_n(i)
					return function(b)
						local actions = require("telescope.actions.set")
						actions.shift_selection(b, -i)
						actions.select(b, "default")
					end
				end

				t.setup({
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown(),
						},
					},
					defaults = {
						layout_config = {
							width = 0.99,
							height = 0.99,
							preview_width = 0.6,
						},
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
								},
							},
						},
					},
				})

				t.load_extension("ui-select")
				t.load_extension("frecency")
				t.load_extension("undo")
			end,
		},

		{ -- LSP configs
			"neovim/nvim-lspconfig",
			dependencies = { "saghen/blink.cmp" },
			lazy = false,
			priority = 999,
			config = function()
				vim.lsp.config("*", {
					root_markers = { ".git" },
					capabilities = require("blink.cmp").get_lsp_capabilities(),
				})

				vim.lsp.enable({
					"nixd",
					"jsonls",
					"eslint",
					"yamlls",
					"terraformls",
					"dockerls",
					"vtsls",
				})
			end,
		},

		{ -- Auto format
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			opts = { notify_on_error = false },
		},

		{ -- Tree-sitter configs
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			build = ":TSUpdate",
			config = function()
				-- Set up treesitter for each buffer (with augroup to prevent duplicates)
				vim.api.nvim_create_autocmd("FileType", {
					group = augroup,
					callback = function(ev)
						if pcall(vim.treesitter.start, ev.buf) then
							vim.wo[vim.fn.bufwinid(ev.buf)].foldexpr = "v:lua.vim.treesitter.foldexpr()"
							vim.wo[vim.fn.bufwinid(ev.buf)].foldmethod = "expr"
							vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						end
					end,
				})
			end,
		},

		{ -- Auto completion
			"saghen/blink.cmp",
			version = "1.*",
			dependencies = { "rafamadriz/friendly-snippets" },
			opts = {
				keymap = { preset = "default" },
				appearance = { nerd_font_variant = "mono" },
				completion = { documentation = { auto_show = true } },
				sources = {
					default = { "lazydev", "lsp", "path", "snippets" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							score_offset = 100,
						},
					},
				},
				signature = { enabled = true },
			},
		},

		{ -- theme
			"navarasu/onedark.nvim",
			config = function()
				require("onedark").load()
			end,
		},

		require("keys").keys,
		require("lang").koka,
		require("lang").purescript,
		require("lang").rust,
		require("lang").javascript,
		require("lang").lua,
	},

	install = { colorscheme = { "onedark" } },
	checker = { enabled = true },
})
