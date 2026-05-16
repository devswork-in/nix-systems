-- This file is managed by Nix-Systems
-- High-priority overrides for auto-save and session persistence

return {
  -- 1. PERSISTENCE (Ensure it's active)
  {
    "folke/persistence.nvim",
    event = "VeryLazy", -- Load late to ensure it doesn't slow down startup
    opts = {},
  },

  -- 2. AUTO-SAVE
  {
    "Pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      debounce_delay = 135,
      execution_message = { message = "" },
    },
  },

  -- 3. THE "BRUTE FORCE" OVERRIDE
  {
    "LazyVim/LazyVim",
    init = function()
      -- Automatically restore session ONLY if starting fresh (no args)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
            pcall(function() require("persistence").load() end)
          end
        end,
      })

      -- Force options
      vim.opt.autowrite = true
      vim.opt.autowriteall = true
      vim.opt.sessionoptions = "curdir,buffers,tabpages,winsize,help,globals,folds,terminal"

      -- THE CATCH-ALL: Save on every possible exit event
      local group = vim.api.nvim_create_augroup("NixSystemsPersistence", { clear = true })
      
      vim.api.nvim_create_autocmd({ "VimLeavePre", "ExitPre" }, {
        group = group,
        callback = function()
          -- Save session
          local ok, persistence = pcall(require, "persistence")
          if ok then persistence.save() end
          -- Save files
          vim.cmd("silent! wa")
        end,
      })

      -- REDEFINE <leader>Q to be bulletproof
      -- Using a nested autocmd to ensure we run AFTER LazyVim sets up its keymaps
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          vim.keymap.set("n", "<leader>Q", function()
            -- Explicit save
            local ok, persistence = pcall(require, "persistence")
            if ok then persistence.save() end
            vim.cmd("silent! wa")
            -- Notify user so they know this version is running
            vim.notify("Saving session and quitting...", vim.log.levels.INFO)
            vim.cmd("qa!") -- Force quit after saving
          end, { desc = "Save everything and Quit", noremap = true, silent = true })
        end,
      })
    end,
  },
}
