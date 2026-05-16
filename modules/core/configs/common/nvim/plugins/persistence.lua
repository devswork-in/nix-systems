return {
  {
    "folke/persistence.nvim",
    event = { "BufReadPre", "VimEnter" }, -- Start session saving on enter or file read
    opts = {
      -- options
    },
    -- Automatically restore session if opening nvim without arguments
    init = function()
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
}
