return {
  "folke/trouble.nvim",
  config = function()
    require("trouble").setup({
      icons = false,
    })

    vim.keymap.set("n", "<leader>tt", "<cmd>Trouble qflist toggle<cr>",
      { silent = true, noremap = true }
    )
  end
}
