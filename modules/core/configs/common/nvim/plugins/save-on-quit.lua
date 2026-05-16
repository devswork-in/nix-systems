return {
  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>Q",
        function()
          -- 1. Force save the current session via persistence
          local ok, persistence = pcall(require, "persistence")
          if ok then
            persistence.save()
          end

          -- 2. Force save all modified buffers
          vim.cmd("silent! wa")

          -- 3. Quit all
          vim.cmd("qa")
        end,
        desc = "Quit and Save All",
      },
    },
  },
}
