-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
--
return {
  [{ "n", "v" }] = {
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
  },
  [{ "n", "t" }] = {
    ["<C-t>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle Term" },
  },
  n = {
    ["<leader>fp"] = {
      function() require("telescope").extensions.projects.projects() end,
      desc = "File in project",
    },
    ["<leader>fr"] = {
      function() require("telescope.builtin").find_files { cwd = "~" } end,
      desc = "File in home",
    },
    ["<leader>fR"] = {
      function() require("telescope.builtin").find_files { cwd = "/" } end,
      desc = "File in root",
    },
    ["<leader>fs"] = {
      function() require("telescope.builtin").find_files { cwd = vim.fn.expand "%:p:h" } end,
      desc = "File in root",
    },
    ["<leader>ff"] = {
      function() require("telescope.builtin").find_files { hidden = true, no_ignore = false } end,
      desc = "File in root",
    },
    ["<leader>FF"] = {
      function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
      desc = "File in root",
    },

    ["<leader>tt"] = { "<cmd>terminal<cr>", desc = "In buffer" },
    ["<A-1>"] = { "1gt" },
    ["<A-2>"] = { "2gt" },
    ["<A-3>"] = { "3gt" },
    ["<A-4>"] = { "4gt" },
    ["<A-5>"] = { "5gt" },
  },
  t = {
    ["<Esc>"] = { "<C-\\><C-n>" },
  },
}
