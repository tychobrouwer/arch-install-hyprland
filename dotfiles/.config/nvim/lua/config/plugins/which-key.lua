return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  filter = function (mapping)
    return mapping.desc and mapping.desc ~= ""
  end,
  opts = {
    preset = "helix",
    spec = {
      { "gd", hidden = true },
      { "K", hidden = true },
      { "[d", hidden = true },
      { "]d", hidden = true },
      { "Y", hidden = true },
      { "%", hidden = true },
      { "&", hidden = true },
      { "<C-L>", hidden = true },
      { "<C-P>", hidden = true },
      { "gx", hidden = true },
      { "g%", hidden = true },
      { "gc", hidden = true },
      { "g'", hidden = true },
      { "g`", hidden = true },
      { "z=", hidden = true },
      { "\"", hidden = true },
      { "'", hidden = true },
      { "[%", hidden = true },
      { "]%", hidden = true },
      { "`", hidden = true },
      { "<C-W>d", hidden = true },
      { "<C-W><C-D>", hidden = true },
      { "<leader>va", hidden = true },
      { "<leader>vd", hidden = true },
      { "<leader>vn", hidden = true },
      { "<leader>vr", hidden = true },
      { "<leader>vs", hidden = true },

      { "<leader>a", desc = "Add file to Harpoon" },
      { "<leader>e", desc = "Toggle Harpoon menu" },
      { "<leader>1", desc = "Harpoon to file 1" },
      { "<leader>2", desc = "Harpoon to file 2" },
      { "<leader>3", desc = "Harpoon to file 3" },
      { "<leader>4", desc = "Harpoon to file 4" },
      { "<leader>t", group = "Trouble" },
      { "<leader>tt", desc = "Open Trouble menu" },
      { "<leader>p", group = "Telescope" },
      { "<leader>pf", desc = "Find files" },
      { "<leader>ps", desc = "Find string in files" },
      { "<leader>pg", desc = "Find string in git files" },
      { "<leader>ps", desc = "Find string in files" },
      { "<leader>pv", desc = "Open Netrw" },
      { "<leader>tt", desc = "Open troubleshoot menu" }
    },
    plugins = {
      presets = {
        operators = false, -- adds help for operators like d, y, ...
        motions = false, -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = false, -- default bindings on <c-w>
        nav = false, -- misc bindings to work with windows
        z = false, -- bindings for folds, spelling and others prefixed with z
        g = false, -- bindings for prefixed with g
      },
    },
    sort = { "manual" },
    icons = {
      group = "",
    },
    loop = true,
  },
}
