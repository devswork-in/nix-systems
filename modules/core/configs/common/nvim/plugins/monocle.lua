local monocle_term = nil

return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      {
        "<leader>rm",
        function()
          if not monocle_term then
            local Terminal = require("toggleterm.terminal").Terminal
            monocle_term = Terminal:new({
              cmd = "monocle",
              dir = "git_dir",
              direction = "vertical",
              size = 65,
              on_open = function(term)
                vim.cmd("startinsert!")
                -- Allow closing with the same keybinding
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<leader>rm", "<cmd>close<CR>", { noremap = true, silent = true })
              end,
            })
          end
          monocle_term:toggle()
        end,
        desc = "Toggle Monocle (Review)",
      },
    },
  },
}
