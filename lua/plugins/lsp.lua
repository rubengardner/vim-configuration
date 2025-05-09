return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local python_path = vim.fn.trim(vim.fn.system("poetry run which python"))

    require("lspconfig").pyright.setup({
      settings = {
        python = {
          pythonPath = python_path,
        },
      },
    })

    require("lspconfig").tsserver.setup({})
  end,
}
