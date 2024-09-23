return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local builtin = require('telescope.builtin')
    local utils = require("telescope.utils")

    vim.keymap.set('n', '<leader>pf', function()
      builtin.find_files({ hidden = true })
    end)

    vim.keymap.set('n', '<leader>pg', function ()
      builtin.git_files({ hidden = true })
    end)

    vim.keymap.set('n', '<leader>ps', function()
      builtin.grep_string({ search = vim.fn.input("Grep > "), hidden = true })
    end)
  end
}

