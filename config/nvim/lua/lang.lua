return {
	{
		"lang/koka",
		virtual = true,
		ft = "koka",
		dependencies = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
		init = function()
			vim.filetype.add({ extension = { kk = "koka" } })
		end,
		config = function()
			vim.lsp.enable("koka")
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
	},
	{
		"lang/purescript",
		virtual = true,
		ft = "purescript",
		dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
		init = function()
			vim.filetype.add({ extension = { purs = "purescript" } })
		end,
		config = function()
			require("conform").formatters_by_ft.purescript = { "purs-tidy" }
			vim.lsp.enable("purescriptls")
			vim.lsp.config("purescriptls", {
				settings = {
					purescript = { addSpagoSources = true },
				},
			})
			require("nvim-treesitter").install({ "purescript" })
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
