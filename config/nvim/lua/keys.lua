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

		local function format()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end

		local function format_all_buffers()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modifiable and vim.bo[buf].buftype == "" then
					require("conform").format({ bufnr = buf, async = true, lsp_format = "fallback" })
				end
			end
		end

		vim.keymap.set("n", "<C-e>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
		vim.keymap.set({ "t", "i", "v", "x" }, "<C-e>", "<C-\\><C-n>", { desc = "Switch to normal mode" })

		return {
			icons = { rules = false, mappings = false },
			spec = {
				{ "<leader>d", desc = "Document" },
				{ "<leader>df", format, desc = "Format" },
				{
					"<leader>di",
					function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end,
					desc = "Inlay Hints",
				},
				{ "<leader>dF", format_all_buffers, desc = "Format All" },
				{ "<leader>de", "<cmd>Telescope diagnostics<CR>", desc = "Errors" },
				{ "<leader>dg", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Grep" },
				{ "<leader>dd", require("dropbar.api").pick, desc = "Dropbar" },

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
				{ "grr", tb.lsp_references, desc = "References" },
				{ "gri", tb.lsp_implementations, desc = "Implementation" },
				{ "gD", vim.lsp.buf.declaration, desc = "Declaration" },

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
