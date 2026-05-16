-- This file is managed by Nix-Systems
-- High-priority overrides for auto-save and session persistence

vim.notify("Nix-Systems: Loading Overrides...", vim.log.levels.INFO)

return {
  -- 1. PERSISTENCE
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
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

  -- 3. BRUTE FORCE OVERRIDES
  {
    "LazyVim/LazyVim",
    init = function()
      -- Force options
      vim.opt.autowrite = true
      vim.opt.autowriteall = true
      vim.opt.sessionoptions = "curdir,buffers,tabpages,winsize,help,globals,folds,terminal"

      -- AUTO-RESTORE
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("NixAutoRestore", { clear = true }),
        callback = function()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
            require("persistence").load()
          end
        end,
        nested = true,
      })

      -- BULLETPROOF <leader>Q
      -- Register it multiple times to ensure we win
      local function apply_quit_fix()
        vim.keymap.set("n", "<leader>Q", function()
          -- Save everything
          pcall(function() require("persistence").save() end)
          vim.cmd("silent! wa")
          -- Final check: if we are still modified, something is wrong
          vim.cmd("qa!")
        end, { desc = "Save and Quit (Nix-Systems)", noremap = true, silent = true })
      end

      -- Run now
      apply_quit_fix()
      -- Run after a delay
      vim.defer_fn(apply_quit_fix, 500)
      -- Run when LazyVim is ready
      vim.api.nvim_create_autocmd("User", { pattern = "LazyVimStarted", callback = apply_quit_fix })
    end,
  },
}
