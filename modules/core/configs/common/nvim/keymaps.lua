local keymap = vim.keymap
local function opts(description)
  return {
    desc = description,
    noremap = true,
    silent = true,
  }
end

-- Override leader Q to ensure everything is saved
keymap.set("n", "<leader>Q", function()
  -- 1. Force save the current session via persistence
  local ok, persistence = pcall(require, "persistence")
  if ok then
    persistence.save()
  end

  -- 2. Force save all modified buffers
  vim.cmd("silent! wa")

  -- 3. Quit all
  vim.cmd("qa")
end, opts("Quit and Save All"))

-- Keep original keymaps from starter repo (we are overwriting the whole file)
-- I will include the common ones from the starter repo I saw earlier
keymap.set("n", "<leader>w", "<cmd>w<CR>", opts("Save file"))
keymap.set("n", "<leader>q", "<cmd>q<CR>", opts("Quit buffer"))
keymap.set("n", "<leader><space>", "<cmd>nohlsearch<CR>", opts("Clear search highlights"))

-- Add any other essential keymaps here
keymap.set("n", "<C-d>", ":bd<CR>", opts("Close current buffer"))
keymap.set("n", "<S-l>", "<cmd>bnext<CR>", opts("Next buffer"))
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", opts("Previous buffer"))

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts("Go to left window"))
keymap.set("n", "<C-j>", "<C-w>j", opts("Go to lower window"))
keymap.set("n", "<C-k>", "<C-w>k", opts("Go to upper window"))
keymap.set("n", "<C-l>", "<C-w>l", opts("Go to right window"))
