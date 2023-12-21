-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local set = vim.keymap.set

local boon = {
  n = { "b" },
  e = { "h" },
  i = { "l" },
  o = { "w" },

  l = { "^" },
  u = { "k" },
  U = { "{" },
  y = { "j" },
  Y = { "}" },
  [";"] = { "$" },

  D = { "s" },
  s = { "i" },
  S = { "I" },
  w = { "u" },
  W = { "<C-r>" },
  t = { "y" },
  tt = { "yy" },
  T = { "yiw" },
}
for k, v in pairs(boon) do
  set({ "n", "v", "s", "o" }, k, v[1])
end

local global = {
  ["<A-1>"] = { "1gt" },
  ["<A-2>"] = { "2gt" },
  ["<A-3>"] = { "3gt" },
  ["<A-4>"] = { "4gt" },
  ["<A-5>"] = { "5gt" },
}
for k, v in pairs(global) do
  set({ "n", "v", "i" }, k, v[1])
end

require("which-key").register({
  P = { "<cmd>Telescope neoclip<cr>", "Find yanks (neoclip)" },
  k = { vim.lsp.buf.hover, "Lsp Hover" },
  ["<leader>"] = {
    p = { "<cmd>Telescope projects<cr>", "Projects" },
    t = { "<cmd>terminal<cr>", "open terminal" },
    b = {
      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
      "Switch Buffer",
    },
    d = {
      function()
        local bd = require("mini.bufremove").delete
        if vim.bo.modified then
          local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
          if choice == 1 then -- Yes
            vim.cmd.write()
            bd(0)
          elseif choice == 2 then -- No
            bd(0, true)
          end
        else
          bd(0)
        end
      end,
      "Delete Buffer",
    },
    w = { "<cmd>w<cr>", "Write Buffer" },
    o = { "<C-W>p", "Other Window" },
    O = { "<C-W>c", "Delete Window" },
  },
})
