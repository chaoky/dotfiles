local M = {}
---@module	'snacks'

local function relativeCwd()
	local _, cwd = pcall(vim.fn.expand, "%:p:h")
	if cwd == "" or type(cwd) ~= "string" then
		cwd = vim.fn.getcwd()
	end
	return cwd
end

local function gitCwd()
	local cmd = vim.system({ "git", "-C", relativeCwd(), "rev-parse", "--show-toplevel" })
	return cmd:wait().stdout:gsub("\n", "", 1)
end

M.fstate = { path = "", all = true }
function M.fargs(func, args)
	args = args or {}

	args.find_command = {
		"rg",
		"--files",
		"--color",
		"never",
		"-g",
		"!node_modules",
		"-g",
		"!target",
		"-g",
		"!dist",
		"-g",
		"!.git",
		"-g",
		"!.spago",
		"-g",
		"!.psci_modules",
		"-g",
		"!output",
		"-g",
		"!generated-docs",
	}
	args.additional_args = {
		"--no-ignore",
		"--hidden",
		"-g",
		"!node_modules",
		"-g",
		"!target",
		"-g",
		"!dist",
		"-g",
		"!.git",
		"-g",
		"!.spago",
		"-g",
		"!.psci_modules",
		"-g",
		"!output",
		"-g",
		"!generated-docs",
	}

	if args.all == false then
		args.find_command = nil
		args.additional_args = { "--no-ignore", "--hidden" }
	end

	if args.no_ignore == nil then
		args.no_ignore = true
	end

	if args.hidden == nil then
		args.hidden = true
	end

	M.fstate = { path = args.cwd or "", all = args.all == nil and true or args.all }
	return func(args)
end

M.keys = { -- Key discovery menu
	"folke/which-key.nvim",
	opts = function()
		local tb = require("telescope.builtin")
		local te = require("telescope").extensions
		local fbrowser = te.file_browser.file_browser

		local function format()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end

		return {
			icons = { rules = false, mappings = false },
			spec = {
				{ "<leader>d", desc = "Document" },
				{ "<leader>df", format, desc = "Format" },
				{ "<leader>de", "<cmd>Telescope diagnostics<CR>", desc = "Errors" },
				{ "<leader>dg", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Grep" },
				{ "<leader>dd", require("dropbar.api").pick, desc = "Dropbar" },
				{ "<leader>dr", vim.lsp.buf.rename, desc = "Rename" },
				{ "<leader>da", vim.lsp.buf.code_action, desc = "Action" },

				{
					"<leader>f",
					function()
						M.fargs(tb.find_files, { cwd = gitCwd() })
					end,
					desc = "Files",
				},
				{
					"<leader>g",
					function()
						M.fargs(tb.live_grep, { cwd = gitCwd() })
					end,
					desc = "Grep",
				},
				{
					"<leader>e",
					function()
						M.fargs(fbrowser, { cwd = relativeCwd() })
					end,
					desc = "Explore",
				},

				{ "<leader>m", desc = "Manage" },
				{ "<leader>mu", "<cmd>Lazy update<cr>", desc = "Update" },
				{ "<leader>mh", "<cmd>Telescope help_tags<cr>", desc = "Help" },

				{ "<leader>s", desc = "Source Control" },
				{
					"<leader>ss",
					function()
						Snacks.lazygit.open({ cwd = gitCwd() })
					end,
					desc = "LazyGit",
				},
				{ "<leader>sb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame" },
				{
					"<leader>sf",
					function()
						Snacks.lazygit.log_file()
					end,
					desc = "File Log",
				},

				{ "<leader>o", te.frecency.frecency, desc = "Old" },
				{
					"<leader><leader>",
					function()
						tb.buffers({ ignore_current_buffer = true })
					end,
					desc = "Buffers",
				},
				{ "<leader>n", "<cmd>Noice dismiss<cr>", desc = "Notification" },
				{
					"<leader>k",
					function()
						Snacks.bufdelete()
					end,
					desc = "Kill Buffer",
				},
				{ "<leader>r", "<cmd>Telescope resume<cr>", desc = "Resume" },

				{ "gd", tb.lsp_definitions, desc = "Definition" },
				{ "gr", tb.lsp_references, desc = "References" },
				{ "gI", tb.lsp_implementations, desc = "Implementation" },
				{ "gD", vim.lsp.buf.declaration, desc = "Declaration" },

				{ "p", "<Plug>(YankyPutAfter)", desc = "Paste" },
				{ "P", "<Plug>(YankyPreviousEntry)", desc = "Paste Previous" },
				{ ";", vim.diagnostic.open_float, desc = "Diagnostic" },

				{ "U", "<cmd>Telescope undo<cr>", desc = "Undo History" },
				{ "m", "<Cmd>e#<CR>", desc = "Move to Alternate" },

				{
					"<C-t>",
					function()
						require("toggleterm").toggle(vim.v.count, nil, gitCwd(), "float")
					end,
					mode = { "n", "t" },
					desc = "Toggle Term",
				},
			},
		}
	end,
}

return M
