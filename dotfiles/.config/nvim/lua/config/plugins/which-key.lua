return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  filter = function (mapping)
    return mapping.desc and mapping.desc ~= ""
  end,
  opts = {
    preset = "helix",
    spec = {
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

      -- Harpoon
      { "<leader>a", desc = "Add file to Harpoon" },
      { "<leader>e", desc = "Toggle Harpoon menu" },
      { "<leader>1", desc = "Harpoon to file 1" },
      { "<leader>2", desc = "Harpoon to file 2", hidden = true },
      { "<leader>3", desc = "Harpoon to file 3", hidden = true },
      { "<leader>4", desc = "Harpoon to file 4", hidden = true },
      { "<leader>!", hidden = true },
      { "<leader>@", hidden = true },
      { "<leader>#", hidden = true },
      { "<leader>$", hidden = true },
      { "<leader><S-1>", desc = "Replace Harpoon file 1" },
      { "<leader><S-2>", desc = "Replace Harpoon file 2", hidden = true },
      { "<leader><S-3>", desc = "Replace Harpoon file 3", hidden = true },
      { "<leader><S-4>", desc = "Replace Harpoon file 4", hidden = true },

      -- Trouble menus
      { "<leader>t", group = "Trouble", icon = "" },
      { "<leader>tt", desc = "Open Trouble quickfix" },
      { "<leader>td", desc = "Open Trouble diagnostics" },

      -- Telescope and search
      { "<leader>p", group = "Telescope" },
      { "<leader>pf", desc = "Find files" },
      { "<leader>pg", desc = "Find git files" },
      { "<leader>ps", desc = "Find string in files" },
      { "<leader>pv", desc = "Open Netrw", icon = "󰉋" },

      -- Lsp configurations
      { "<leader>v", group = "Lsp", icon = "󰒋" },
      { "<leader>va", desc = "Code action" },
      { "<leader>vd", desc = "Open definition" },
      { "<leader>vn", desc = "Rename symbol", icon = "󰑕" },
      { "<leader>vr", desc = "Search references" },
      { "<leader>vs", desc = "Search workspace symbol" },
      { "<leader>vk", desc = "Open symbol hover", icon = "" },
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
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Local keybinds",
    },
  },
}
