-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("n", "<leader>tt", ":TestNearest<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>tf", ":TestFile<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>tl", ":TestLast<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-s>", ":w <CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-s>", "<Esc>:w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-s>", "<Esc>:w<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-Right>", "<End>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-Left>", "<C-o>^", { noremap = true, silent = true })

vim.keymap.set("n", "<C-Right>", "$", { noremap = true, silent = true }) -- Go to end of line
vim.keymap.set("n", "<C-Left>", "^", { noremap = true, silent = true }) -- Go to first non-blank character
vim.keymap.set("n", "<C-l>", "$", { noremap = true, silent = true }) -- Move to end of line
vim.keymap.set("n", "<C-h>", "^", { noremap = true, silent = true }) -- Move to first non-blank characte

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "<leader>rr", function()
  local old = vim.fn.input("Find: ")
  local new = vim.fn.input("Replace with: ")
  if old ~= "" then
    vim.cmd(string.format("%%s/%s/%s/gc", old, new))
  end
end, { noremap = true, silent = false })
vim.keymap.set("n", "t", ":FindTest<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-e>", "<C-^>", { noremap = true, silent = true, desc = "Go to last file" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set(
  "n",
  "<leader>ss",
  ":e ~/PycharmProjects/badger-app/badger-go/monolith/badgermapping/settings_local.py<CR>",
  { noremap = true, silent = true, desc = "GO Settings Local" }
)
