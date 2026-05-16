-- This file is managed by Nix-Systems
-- It overlays aggressive auto-save and session persistence on top of the starter config

return {
  -- 1. PERSISTENCE (Session saving)
  {
    "folke/persistence.nvim",
    event = { "BufReadPre", "VimEnter" },
    opts = {},
    init = function()
      -- Automatically restore session if opening nvim without arguments
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("PersistenceAutoRestore", { clear = true }),
        callback = function()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
            require("persistence").load()
          end
        end,
      })
    end,
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- 2. AUTO-SAVE (File saving)
  {
    "Pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      debounce_delay = 135,
      execution_message = { message = "" },
    },
  },

  -- 3. GLOBAL OVERRIDES (Runs on startup)
  {
    "LazyVim/LazyVim",
    -- Using init ensures this runs early and consistently
    init = function()
      -- Force these options even if lua/config/options.lua says otherwise
      vim.opt.autowrite = true
      vim.opt.autowriteall = true
      vim.opt.updatetime = 200
      vim.opt.sessionoptions = "curdir,buffers,tabpages,winsize,help,globals,folds,terminal"
      vim.opt.shada = "!,'100,<50,s10,h"

      -- OVERRIDE <leader>Q
      -- We use a timer to ensure this runs AFTER core keymaps are loaded
      vim.defer_fn(function()
        vim.keymap.set("n", "<leader>Q", function()
          -- Save session safely
          local p_ok, persistence = pcall(require, "persistence")
          if p_ok then
            pcall(persistence.save)
          end
          
          -- Save all files
          vim.cmd("silent! wa")
          
          -- Quit all
          vim.cmd("qa")
        end, { desc = "Quit and Save All", noremap = true, silent = true })
      end, 200)

      -- Add FocusLost fallback
      vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "VimLeavePre" }, {
        callback = function()
          if vim.bo.modifiable and vim.bo.modified and vim.fn.expand("%") ~= "" then
            vim.cmd("silent! update")
          end
        end,
      })
    end,
  },
}
