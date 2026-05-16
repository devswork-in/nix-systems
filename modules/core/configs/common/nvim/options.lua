-- Aggressive session and file saving options
vim.opt.autosave = true
vim.opt.autowrite = true
vim.opt.autowriteall = true

-- Save session information frequently (default is 4000ms)
vim.opt.updatetime = 200

-- Ensure ShaDa (shared data) is saved on exit
-- ' means mark session files, < means max lines, f means save marks
vim.opt.shada = "!,'100,<50,s10,h"

-- Automatically save everything when Neovim loses focus
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "VimLeavePre" }, {
  callback = function()
    vim.cmd("silent! wa")
  end,
})
