local pi_term = nil

-- Helper to get Pi session directory format from path
local function get_session_dir()
  local cwd = vim.fn.getcwd()
  local session_dir = cwd:gsub("^/", ""):gsub("/$", ""):gsub("/", "-")
  return "--" .. session_dir .. "--"
end

-- Helper to check if a Pi session exists for the current directory
local function has_pi_session()
  local session_path = vim.fn.expand("~/.pi/agent/sessions/") .. get_session_dir()
  return vim.fn.isdirectory(session_path) == 1
end

return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      -- 1. PI AGENT (Resume/Toggle)
      {
        "<leader>ap",
        function()
          if not pi_term then
            local Terminal = require("toggleterm.terminal").Terminal
            pi_term = Terminal:new({
              cmd = "pi -r",
              dir = "git_dir",
              direction = "float",
              float_opts = {
                border = "rounded",
                width = math.floor(vim.o.columns * 0.85),
                height = math.floor(vim.o.lines * 0.85),
              },
              on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<leader>ap", "<cmd>close<CR>", { noremap = true, silent = true })
              end,
            })
          end
          pi_term:toggle()
        end,
        desc = "Toggle Pi Agent (Resume)",
      },

      -- 3. PI AGENT (New Session)
      {
        "<leader>an",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local new_pi = Terminal:new({
            cmd = "pi",
            dir = "git_dir",
            direction = "float",
            close_on_exit = true,
            float_opts = {
              border = "rounded",
              width = math.floor(vim.o.columns * 0.85),
              height = math.floor(vim.o.lines * 0.85),
            },
            on_open = function(term)
              vim.cmd("startinsert!")
            end,
          })
          new_pi:toggle()
        end,
        desc = "New Pi Agent Session",
      },

      -- 4. PI SESSIONS (Selector Menu)
      {
        "<leader>as",
        function()
          local options = { "󰁯 Resume Current", "󰝒 New Session", "󰒲 List All" }
          vim.ui.select(options, { prompt = "Pi Agent Action" }, function(choice)
            if not choice then return end
            
            local cmd = "pi"
            if choice == "󰁯 Resume Current" or choice == "󰒲 List All" then
              cmd = "pi -r"
            end

            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new({
              cmd = cmd,
              dir = "git_dir",
              direction = "float",
              close_on_exit = (choice == "󰒲 List All"),
              float_opts = {
                border = "double",
                width = math.floor(vim.o.columns * 0.85),
                height = math.floor(vim.o.lines * 0.85),
              },
              on_open = function(term)
                vim.cmd("startinsert!")
              end,
            })
            term:spawn()
          end)
        end,
        desc = "Pi Agent Sessions Menu",
      },
    },
  },
}
