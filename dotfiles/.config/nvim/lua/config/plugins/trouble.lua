return {
  "folke/trouble.nvim",
  config = function()
    require("trouble").setup({});

    vim.keymap.set("n", "<leader>tt", "<cmd>Trouble qflist toggle<cr>",
      { silent = true, noremap = true }
    );

    vim.keymap.set("n", "<leader>td", "<cmd>Trouble diagnostics toggle<cr>",
      { silent = true, noremap = true }
    );
  end
}
