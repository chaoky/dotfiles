local M = {}
---@module	'snacks'

local ignore_patterns = {
	"!node_modules",
	"!target",
	"!dist",
	"!.git",
	"!.spago",
	"!.psci_modules",
	"!output",
	"!generated-docs",
}

local function make_glob_args(patterns)
	local result = {}
	for _, p in ipairs(patterns) do
		table.insert(result, "-g")
		table.insert(result, p)
	end
	return result
end

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

	local glob_args = make_glob_args(ignore_patterns)
	args.find_command = vim.list_extend({ "rg", "--files", "--color", "never" }, glob_args)
	args.additional_args = vim.list_extend({ "--no-ignore", "--hidden" }, glob_args)

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

		vim.keymap.set("n", "<C-e>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
		vim.keymap.set({ "t", "i", "v", "x" }, "<C-e>", "<C-\\><C-n>", { desc = "Switch to normal mode" })

		return {
			icons = { rules = false, mappings = false },
			spec = {
				{ "<leader>d", desc = "Document" },
				{
					"<leader>df",
					function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end,
					desc = "Format",
				},
				{
					"<leader>di",
					function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end,
					desc = "Inlay Hints",
				},
				{ "<leader>dd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
				{ "<leader>dt", "<cmd>Telescope treesitter<CR>", desc = "Treesitter" },
				{ "<leader>t", require("dropbar.api").pick, desc = "Topbar" },

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
						require("fyler").toggle({ kind = "split_left_most" })
					end,
					desc = "Explore",
				},

				{ "<leader>m", desc = "Manage" },
				{ "<leader>mu", "<cmd>Lazy update<cr>", desc = "Update" },
				{ "<leader>mh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
				{ "<leader>mk", tb.keymaps, desc = "Keymaps" },
				{ "<leader>mm", tb.marks, desc = "Marks" },

				{ "<leader>s", desc = "Source" },
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
				{ "<leader>sp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
				{ "<leader>sa", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Hunk" },
				{ "<leader>sr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Hunk" },
				{ "<leader>sd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff" },
				{ "<leader>sc", tb.git_commits, desc = "Commits" },

				{ "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Hunk" },
				{ "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous Hunk" },

				{ "<leader>o", te.frecency.frecency, desc = "Old" },
				{
					"<leader><leader>",
					function()
						tb.buffers({ ignore_current_buffer = true })
					end,
					desc = "Buffers",
				},
				{ "<leader>n", desc = "Notification" },
				{ "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss" },
				{ "<leader>nh", "<cmd>Noice telescope<cr>", desc = "History" },
				{
					"<leader>k",
					function()
						Snacks.bufdelete()
					end,
					desc = "Kill Buffer",
				},
				{ "<leader>r", "<cmd>Telescope resume<cr>", desc = "Resume" },

				{ "gra", vim.lsp.buf.code_action, desc = "Action" },
				{ "grn", vim.lsp.buf.rename, desc = "Rename" },
				{ "grr", tb.lsp_references, desc = "References" },
				{ "gri", tb.lsp_implementations, desc = "Implementation" },
				{ "grt", tb.lsp_type_definitions, desc = "Type Definitions" },
				{ "gd", tb.lsp_definitions, desc = "Definition" },

				{ "p", "<Plug>(YankyPutAfter)", desc = "Paste", mode = { "n", "x" } },
				{ "p", "<Plug>(YankyPutAfter)", desc = "Paste", mode = { "n", "x" } },
				{ "P", "<Plug>(YankyPutBefore)", desc = "Paste", mode = { "n", "x" } },
				{ "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Paste Previous" },
				{ "<c-n>", "<Plug>(YankyNextEntry)", desc = "Paste next" },

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
