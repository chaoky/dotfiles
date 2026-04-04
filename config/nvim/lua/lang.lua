return {
	{
		"lang/koka",
		virtual = true,
		ft = "koka",
		dependencies = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
		init = function()
			vim.filetype.add({ extension = { kk = "koka" } })
			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = function()
					require("nvim-treesitter.parsers").koka = {
						install_info = {
							url = "https://github.com/koka-community/tree-sitter-koka",
							revision = "main",
							files = { "src/parser.c", "src/scanner.c" },
						},
						filetype = "koka",
						tier = 0,
					}
				end,
			})
		end,
		config = function()
			vim.lsp.enable("koka")
			require("nvim-treesitter").install({ "koka" })
		end,
	},
	{
		"lang/purescript",
		virtual = true,
		ft = { "purescript", "dhall" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
		init = function()
			vim.filetype.add({ extension = { purs = "purescript", dhall = "dhall" } })
			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = function()
					require("nvim-treesitter.parsers").dhall = {
						install_info = {
							url = "https://github.com/jbellerb/tree-sitter-dhall",
							revision = "master",
							files = { "src/parser.c", "src/scanner.c" },
						},
						filetype = "dhall",
						tier = 0,
					}
				end,
			})
		end,
		config = function()
			require("conform").formatters_by_ft.purescript = { "purs-tidy" }
			require("conform").formatters_by_ft.dhall = { "dhall" }
			vim.lsp.enable("purescriptls")
			vim.lsp.enable("dhall_lsp_server")
			vim.lsp.config("purescriptls", {
				settings = {
					purescript = { addSpagoSources = true },
				},
			})
			require("nvim-treesitter").install({ "purescript", "dhall" })
		end,
	},
	{
		"lang/rust",
		virtual = true,
		ft = "rust",
		dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("conform").formatters_by_ft.rust = { "rustfmt", lsp_format = "fallback" }
			vim.lsp.enable("rust_analyzer")
			vim.lsp.config("rust_analyzer", {
				settings = {
					["rust-analyzer"] = {
						cargo = { targetDir = true },
					},
				},
			})
			require("nvim-treesitter").install({ "rust" })
		end,
	},
	{
		"lang/javascript",
		virtual = true,
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("conform").formatters_by_ft.javascript =
				{ "prettierd", "prettier", "biome", stop_after_first = true }
			require("conform").formatters_by_ft.typescript =
				{ "prettierd", "prettier", "biome", stop_after_first = true }
			vim.lsp.enable("vtsls")
			vim.lsp.enable("eslint")
			require("nvim-treesitter").install({ "typescript", "javascript" })
		end,
	},
	{
		"lang/ocaml",
		virtual = true,
		ft = { "ocaml", "ocaml_interface", "ocamllex", "menhir" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("conform").formatters_by_ft.ocaml = { "ocamlformat" }
			vim.lsp.enable("ocamllsp")
			require("nvim-treesitter").install({ "ocaml", "ocaml_interface" })
		end,
	},
	{
		"lang/lua",
		virtual = true,
		ft = "lua",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/conform.nvim",
			"folke/lazydev.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("conform").formatters_by_ft.lua = { "stylua" }
			require("lazydev").setup({
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			})
			vim.lsp.enable("lua_ls")
			require("nvim-treesitter").install({ "lua" })
		end,
	},
}
