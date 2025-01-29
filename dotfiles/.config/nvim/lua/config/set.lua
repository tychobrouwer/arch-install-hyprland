vim.opt.nu = true -- display line number current line
vim.opt.relativenumber = true -- display relative line numbers

vim.opt.tabstop = 2 -- number of spaces that count as tab
vim.opt.softtabstop = 2 -- number of spaces for tab
vim.opt.shiftwidth = 2 -- number of spaces for autoindent
vim.opt.expandtab = true -- use spaces for tab

vim.opt.autoindent = true -- copy indent from current line for new line
vim.opt.smartindent = true -- smart indent for new line

vim.opt.breakindent = true -- visually continue wrapped line at indent
vim.opt.linebreak = true -- wrap on 'breakat' characters

vim.opt.undofile = true -- save undo history in file
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"

vim.opt.termguicolors = true -- enable 24bit colors 

vim.opt.updatetime = 1000 -- update swap file interval
vim.opt.updatecount = 10 -- update swap file after 10 characters

vim.opt.hlsearch = true -- highlight all search matches

vim.opt.spell = true -- enable spell checking
vim.opt.spellfile = os.getenv("HOME") .. "/.config/nvim/spellfile.utf-8.add"
vim.opt.spelllang = "en" -- set spell checking to english
vim.opt.spelloptions = "camel" -- separate words for camel case

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', space = '·', nbsp = '␣' }

