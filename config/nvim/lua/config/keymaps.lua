-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

-- floating terminal
del("n", "<leader>fT")
del("n", "<leader>ft")
del("n", "<c-/>")
del("n", "<c-_>")
map({ "n", "t" }, "<C-t>", '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>', { desc = "Toggle Term" })

-- Terminal Mappings
del("t", "<C-/>")
del("t", "<c-_>")

map("n", "<C-e>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
map({ "t", "i", "v", "x" }, "<C-e>", "<C-\\><C-n>", { desc = "Switch to nomal mode" })
