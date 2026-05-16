-- Aggressive session and file saving options
vim.opt.autowrite = true
vim.opt.autowriteall = true

-- Save session information frequently
vim.opt.updatetime = 200

-- Session options for persistence (ensure terminals and folds are saved)
vim.opt.sessionoptions = "curdir,buffers,tabpages,winsize,help,globals,folds,terminal"

-- Ensure ShaDa (shared data) is saved on exit
vim.opt.shada = "!,'100,<50,s10,h"

-- Automatically save everything when Neovim loses focus or is about to exit
-- This ensures that even if auto-save.nvim is debouncing, we catch the save.
local save_group = vim.api.nvim_create_augroup("AggressiveSave", { clear = true })
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "VimLeavePre", "BufWinLeave" }, {
  group = save_group,
  callback = function()
    if vim.bo.modifiable and vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})

-- Force save all buffers on quit
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = save_group,
  callback = function()
    vim.cmd("silent! wa")
  end,
})
