return {
  'theprimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>a", mark.add_file)
    vim.keymap.set("n", "<leader>e", ui.toggle_quick_menu)

    vim.keymap.set("n", "<leader>!", function() mark.set_current_at(1) end)
    vim.keymap.set("n", "<leader>@", function() mark.set_current_at(2) end)
    vim.keymap.set("n", "<leader>#", function() mark.set_current_at(3) end)
    vim.keymap.set("n", "<leader>$", function() mark.set_current_at(4) end)

    vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
    vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
    vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
    vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
  end
}
