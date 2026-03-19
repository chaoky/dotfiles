local M = {}

M.koka = {
	name = "koka",
	dir = ".",
	dependencies = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
	config = function()
		vim.filetype.add({ extension = { kk = "koka" } })
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
}

M.purescript = {
	name = "purescript",
	dir = ".",
	dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
	config = function()
		require("conform").formatters_by_ft.purescript = { "purs-tidy" }
		vim.filetype.add({ extension = { purs = "purescript" } })
		vim.lsp.enable("purescriptls")
		vim.lsp.config("purescriptls", {
			settings = {
				purescript = { addSpagoSources = true },
			},
		})
		require("nvim-treesitter").install({ "purescript" })
	end,
}

M.rust = {
	name = "rust",
	dir = ".",
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
}

M.javascript = {
	name = "javascript",
	dir = ".",
	dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "neovim/nvim-lspconfig" },
	config = function()
		require("conform").formatters_by_ft.javascript = { "prettierd", "prettier", "biome", stop_after_first = true }
		require("conform").formatters_by_ft.typescript = { "prettierd", "prettier", "biome", stop_after_first = true }
		vim.lsp.config("vtsls", {
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		})
		vim.lsp.enable("vtsls")
		require("nvim-treesitter").install({ "typescript", "javascript" })
	end,
}

M.lua = {
	name = "lua",
	dir = ".",
	dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/conform.nvim", "folke/lazydev.nvim", "neovim/nvim-lspconfig" },
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
}

return M
