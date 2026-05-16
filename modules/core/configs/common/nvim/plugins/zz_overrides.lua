-- This file is managed by Nix-Systems
-- High-priority overrides for auto-save and session persistence

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

  -- 3. NEO-TREE (Cleaner UI)
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["<leader>Q"] = "none",
        }
      },
      source_selector = {
        winbar = false,
        statusline = false,
      },
      hide_root_node = true,
      retain_hidden_root_indent = true,
    },
  },

  -- 4. BUFFERLINE (Remove "Neo-tree" sidebar title)
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.offsets = opts.options.offsets or {}
      for _, offset in ipairs(opts.options.offsets) do
        if offset.filetype == "neo-tree" then
          offset.text = "" -- Kill the text
        end
      end
      return opts
    end,
  },

  -- 5. BRUTE FORCE OVERRIDES
  {
    "LazyVim/LazyVim",
    init = function()
      -- Force options
      vim.opt.autowrite = true
      vim.opt.autowriteall = true
      vim.opt.sessionoptions = "curdir,buffers,tabpages,winsize,help,globals,folds,terminal"
      vim.opt.winbar = "" -- Globally disable winbar just in case

      -- FORCE DISABLE WINBAR (This kills the "Neo-tree" text)
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
        pattern = "neo-tree",
        callback = function()
          vim.schedule(function()
            vim.opt_local.winbar = ""
            -- Force redraw
            vim.cmd("redrawstatus")
          end)
        end,
      })

      -- AUTO-RESTORE
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("NixAutoRestore", { clear = true }),
        callback = function()
          -- Allow restore if:
          -- 1. No arguments are passed (nvim)
          -- 2. Exactly one directory argument is passed (nvim .)
          local argc = vim.fn.argc()
          local should_restore = (argc == 0) or (argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1)

          if should_restore and not vim.g.started_with_stdin then
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
